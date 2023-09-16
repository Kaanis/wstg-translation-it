#!/bin/bash
# Script per creare l'EPUB file della WSTG
# Questo script viene eseguito dopo la creazione del PDF
# Alcune dipendenze sono risolte nella creazione del PDF

# Pulisce e crea le cartelle di build richieste
clean_build () {
    # Pulisce la cartella della build
    rm -rf build/epub
    # Crea le cartelle di build richieste
    mkdir -p build/epub
}

# Prepara la cartella di build con i file necessari 
prepare_build () {
    # Estrae il numero di versione dal tag di versione
    VERSION_NUMBER=`echo $VERSION | sed 's/v//'`
    METADATA_FILE="../../.github/epub/assets/epub-metadata.yaml"
    # Copia le immagini nella cartella temporanea per generare PDF relativi ai capitoli
    # Le immagini devono essere aggiunte alla build durante la creazione del PDF
    cp -r build/images build/epub/
}

# Crea il file di Markdown per la copertina anteriore e genera la copertina con md-to-pdf
set_front_cover_vars () {
# Crea l'immagine di copertina con il numero di versione dell'immagine se esistente altrimenti usa quella di default con numero di versione
VERSIONED_COVER_IMAGE_FILE=images/book-cover-$VERSION.jpg
if [[ -f "build/$VERSIONED_COVER_IMAGE_FILE" ]]; then
    # Se il numero di versione dell'immagine è esistente imposta le opzioni per l'immagine di copertina
    VERSIONED_COVER_IMAGE_FILE_OPTION="--epub-cover-image=$VERSIONED_COVER_IMAGE_FILE"
    VERSIONED_COVER_MARKDOWN_FILE=""
else
    VERSIONED_COVER_IMAGE_FILE_OPTION=""
    # Il Markdown della copertina dovrebbe essere generato durante la creazione del PDF
    VERSIONED_COVER_MARKDOWN_FILE="../cover-$VERSION.md"

fi

}

# Aggiunge l'interruzione di pagina dopo ogni capitolo
add_page_break () {
    echo '<div style="page-break-after: always;"></div>'
}

# Rimpiazza i Link di markdown interni dentro gli headings con anchor tags html 
# all'interno del rispettivo tag di intestazione ( <h1>, <h2> ... ) e l'href del link come testo dell'intestazione
# esempio: ## 0. [Foreword by Eoin Keary](0-Foreword/README.md)  ->  <h2><a href="Foreword by Eoin Keary">Foreword by Eoin Keary</a></h2>
# Gli spazi all'interno dell'href saranno gestiti successivamente.
replace_internal_markdown_links_with_in_headers_with_html_tags () {
    sed 's/\(^#\{2\} \)\(\[\(.*\)\]\(.*\)\(\?\:\n\+\|$\)\)/<h2><a href=\"#\3\">\3<\/a><\/h2>/'  | \
    sed 's/\(^#\{1\} \)\([0-9. ]*\) \(\[\(.*\)\]\(.*\)\(\?\:\n\+\|$\)\)/<h1>\2 <a href=\"#\4\">\4<\/a><\/h1>/'  | \
    sed 's/\(^#\{2\} \)\([0-9. ]*\) \(\[\(.*\)\]\(.*\)\(\?\:\n\+\|$\)\)/<h2>\2 <a href=\"#\4\">\4<\/a><\/h2>/' | \
    sed 's/\(^#\{2\} \)\(Appendix [ABCDEF]\.\) \(\[\(.*\)\]\(.*\)\(\?\:\n\+\|$\)\)/<h2>\2 <a href=\"#\4\">\4<\/a><\/h2>/' | \
    sed 's/\(^#\{3\} \)\([0-9. ]*\) \(\[\(.*\)\]\(.*\)\(\?\:\n\+\|$\)\)/<h3>\2 <a href=\"#\4\">\4<\/a><\/h3>/'| \
    sed 's/\(^#\{4\} \)\([0-9. ]*\) \(\[\(.*\)\]\(.*\)\(\?\:\n\+\|$\)\)/<h4>\2 <a href=\"#\4\">\4<\/a><\/h4>/' | \
    sed 's/\(^#\{5\} \)\([0-9. ]*\) \(\[\(.*\)\]\(.*\)\(\?\:\n\+\|$\)\)/<h5>\2 <a href=\"#\4\">\4<\/a><\/h5>/' $1
}

# Replace internal markdown Links with html anchor tags (<a>)
# Set link href as the heading text, Remove subsection numbers from href.
# Exclude links starts with http, make sure not to replace external links
# eg: [testing browser storage](../11-Client-side_Testing/12-Testing_Browser_Storage.md) ->
#     <a href="Testing_Browser_Storage.md">testing browser storage</a>
# Underscore and .md in the href addressed in later steps
replace_internal_markdown_links_with_html_tags () {
    # Appendix internal links.
    sed '/[\[^\[\]*](http[^\[]*\.md)/! s/\[\([^\[]*\)\]([^\[]*[ABCDEF]-\([^(]*\.md\))/<a href=\"#\2\">\1<\/a>/g' | \
    # For all other internal links.
    sed '/[\[^\[\]*](http[^\[]*\.md)/! s/\[\([^\[]*\)\]([^\[]*[0-9]\-\([^(]*\.md\))/<a href=\"#\2\">\1<\/a>/g' $1
}

# Replace Markdown links with fragment identifiers with html <a> tag.
# Remove file path and keep fragment identifier alone.
# Exclude urls start with http (Helps to exclude urls to external markdown files with fragment)
# eg: [Identify Application Entry Points](06-Identify_Application_Entry_Points.md#v74-error-handling) ->
#     <a href="#v74-error-handling">Identify Application Entry Points</a>
replace_internal_markdown_links_having_fragments_with_html_tags () {
    sed '/[\[^\[\]*](http[^\[]*\.md#\([^\)]\+\))/! s/\[\([^\n]\+\)\]([^\n]\+.md#\([^\)]\+\))/<a href=\"#\2\">\1<\/a>/' | \
    # Links with fragment identifiers alone
    sed 's/\[\([^\[]\+\)\](#\([^\)]\+\))/<a href=\"#\2\">\1<\/a>/' $1
}

# Convert all chars inside href to lower case
# Handles the href with .md extention ( Keeps this .md inside the href to identify internal markdown links)
convert_internal_markdown_href_to_lower_case () {
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*\.md)\"', lambda m: m.group().lower(), sys.stdin.read()))"
}

# Replace the spaces and _ inside `href` values with hyphen
# Handles the href with .md extention ( Keeps this .md inside the href to identify internal markdown links)
replace_space_and_underscore_with_hyphen_in_internal_markdown_href () {
    # Replace space and underscore
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*\.md)\"', lambda m: m.group().replace(' ', '-').replace('_', '-'), sys.stdin.read()))"
}

# Remove readme.md and .md extentions from href
# This extention inside href used to identify the internal markdown links
remove_markdown_file_extention_from_href () {
    # Remove readme.md
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*/readme\.md)\"', lambda m: m.group().replace('/readme.md', ''), sys.stdin.read()))"  | \
    # Remove .md
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*\.md)\"', lambda m: m.group().replace('.md', ''), sys.stdin.read()))"
}

# Replace the spaces inside 'id' value with hyphen
replace_space_with_hyphen_in_id () {
    python -c "import re; import sys; print(re.sub(r'id=\"([^\n]+)\"', lambda m: m.group().replace(' ', '-'), sys.stdin.read()))"
}

# Convert all chars inside id to lower case
convert_id_to_lower_case () {
    python -c "import re; import sys; print(re.sub(r'id=\"([^\n]+)\"', lambda m: m.group().lower(), sys.stdin.read()))"
}

# Remove `:`, `,`, `.` inside id values
remove_special_chars_from_id () {
    python -c "import re; import sys; print(re.sub(r'id=\"([^\n]+)\"', lambda m: m.group().replace(':', '').replace(':', '').replace('.', '').replace(',', ''), sys.stdin.read()))"
}

# Replace spaces with hyphen inside href value
replace_space_with_hyphen_in_href () {
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*)\"', lambda m: m.group().replace(' ', '-'), sys.stdin.read()))"
}

# Convert all chars inside href to lower case
convert_href_to_lower_case () {
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*)\"', lambda m: m.group().lower(), sys.stdin.read()))"
}

# Move chapter number out of href links
remove_chapter_numbers_from_link () {
    sed 's/<h1 id=\"[0-9.]*-\(.*\)\">\(.*\)<\/h1>/<h1 id="\1">\2<\/h1>/' $1
}

# Preprocess markdown files to support internal links and image designs
preprocess_markdown_to_support_md_to_pdf () {
    cat build/md/$1 | \
    replace_internal_markdown_links_with_in_headers_with_html_tags | \
    replace_internal_markdown_links_with_html_tags | \
    # Sed section: Workaround to address the bug in duplicate fragment links in 4.1.
    sed 's/\[\([^\n]\+\)\](#tools)/\1/i' |\
    sed 's/\[\([^\n]\+\)\](#references)/\1/i' |\
    sed 's/\[\([^\n]\+\)\](#Remediation)/\1/i' |\
    sed 's/\[\([^\n]\+\)\]([^\n]\+.md#remediation)/\1/i' | \
    replace_internal_markdown_links_having_fragments_with_html_tags |\
    convert_internal_markdown_href_to_lower_case  | \
    replace_space_and_underscore_with_hyphen_in_internal_markdown_href | \
    remove_markdown_file_extention_from_href | \
    replace_space_with_hyphen_in_id | \
    convert_id_to_lower_case  | \
    remove_special_chars_from_id  | \
    replace_space_with_hyphen_in_href  | \
    convert_href_to_lower_case | \
    { remove_chapter_numbers_from_link; add_page_break;}
}


# ---------------------------------------------------------------------------------------------

VERSION=$1
echo "Creating EPUB for version $VERSION"

clean_build

prepare_build

set_front_cover_vars

# Create chapter wise markdown files
ls build/md | sort -n | while read x; do  preprocess_markdown_to_support_md_to_pdf $x >  build/epub/$x ; done

# Rimuove il file TOC
rm build/epub/document\>\>\>0-0.0_README.md

cd build/epub/

pandoc $VERSIONED_COVER_IMAGE_FILE_OPTION -o ../wstg-$VERSION.epub $VERSIONED_COVER_MARKDOWN_FILE ../second-cover-$VERSION.md *.md ../back-$VERSION.md \
    --table-of-contents --toc-depth=1 --metadata title="Web Security Testing Guide" --metadata subtitle="Version : $VERSION" --css="../../.github/epub/assets/epub-style.css"

