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

# Rimpiazza i Link di markdown interni dentro gli headings con anchor tags html (<a>)
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

# Rimpiazza i Link di markdown interni dentro gli headings con anchor tags html (<a>)
# Imposta l'href del link come testo dell'intestazione, rimuove i numeri delle sottosezioni dall'href.
# Esclude i collegamenti che iniziano con http, assicurarsi di non sostituire i collegamenti esterni
# esempio: [testing browser storage](../11-Client-side_Testing/12-Testing_Browser_Storage.md) ->
#     <a href="Testing_Browser_Storage.md">testing browser storage</a>
# Underscore e .md nell'href saranno gestiti successivamente.
replace_internal_markdown_links_with_html_tags () {
    # Appendice collegamenti interni.
    sed '/[\[^\[\]*](http[^\[]*\.md)/! s/\[\([^\[]*\)\]([^\[]*[ABCDEF]-\([^(]*\.md\))/<a href=\"#\2\">\1<\/a>/g' | \
    # Per tutti gli altri link interni.
    sed '/[\[^\[\]*](http[^\[]*\.md)/! s/\[\([^\[]*\)\]([^\[]*[0-9]\-\([^(]*\.md\))/<a href=\"#\2\">\1<\/a>/g' $1
}

# Sostituisce i collegamenti nel Markdown con identificatori di frammenti con il tag html <a>.
# Rimuove il percorso del file e mantiene solo l'identificatore del frammento.
# Esclude gli URL che iniziano con http (aiuta a escludere gli URL a file markdown esterni con frammenti).
# esempio: [Identify Application Entry Points](06-Identify_Application_Entry_Points.md#v74-error-handling) ->
#     <a href="#v74-error-handling">Identify Application Entry Points</a>
replace_internal_markdown_links_having_fragments_with_html_tags () {
    sed '/[\[^\[\]*](http[^\[]*\.md#\([^\)]\+\))/! s/\[\([^\n]\+\)\]([^\n]\+.md#\([^\)]\+\))/<a href=\"#\2\">\1<\/a>/' | \
    # Collegamenti con i soli identificatori di frammenti
    sed 's/\[\([^\[]\+\)\](#\([^\)]\+\))/<a href=\"#\2\">\1<\/a>/' $1
}

# Converte tutti i caratteri all'interno di href in minuscolo
# Gestisce l'href con estensione .md (mantiene questo .md all'interno dell'href per identificare i collegamenti interni al markdown)
convert_internal_markdown_href_to_lower_case () {
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*\.md)\"', lambda m: m.group().lower(), sys.stdin.read()))"
}

# Sostituisce gli spazi e _ all'interno dei valori `href` con il trattino
# Gestisce l'href con estensione .md (mantiene questo .md all'interno dell'href per identificare i collegamenti interni al markdown)
replace_space_and_underscore_with_hyphen_in_internal_markdown_href () {
    # Sostituisce gli spazi e i trattini bassi
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*\.md)\"', lambda m: m.group().replace(' ', '-').replace('_', '-'), sys.stdin.read()))"
}

# Rimuove le estensioni readme.md e .md da href
# Questa estensione all'interno di href è usata per identificare i collegamenti interni al markdown.
remove_markdown_file_extention_from_href () {
    # Rimuove readme.md
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*/readme\.md)\"', lambda m: m.group().replace('/readme.md', ''), sys.stdin.read()))"  | \
    # Rimuove .md
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*\.md)\"', lambda m: m.group().replace('.md', ''), sys.stdin.read()))"
}

# Sostituisce gli spazi all'interno del valore 'id' con il trattino
replace_space_with_hyphen_in_id () {
    python -c "import re; import sys; print(re.sub(r'id=\"([^\n]+)\"', lambda m: m.group().replace(' ', '-'), sys.stdin.read()))"
}

# Converte tutti i caratteri all'interno dell'id in minuscolo
convert_id_to_lower_case () {
    python -c "import re; import sys; print(re.sub(r'id=\"([^\n]+)\"', lambda m: m.group().lower(), sys.stdin.read()))"
}

# Rimuove `:`, `,`, `.` dai valori id interni
remove_special_chars_from_id () {
    python -c "import re; import sys; print(re.sub(r'id=\"([^\n]+)\"', lambda m: m.group().replace(':', '').replace(':', '').replace('.', '').replace(',', ''), sys.stdin.read()))"
}

# Sostituisce gli spazi con il trattino all'interno del valore href
replace_space_with_hyphen_in_href () {
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*)\"', lambda m: m.group().replace(' ', '-'), sys.stdin.read()))"
}

# Converte tutti i caratteri all'interno di href in minuscolo
convert_href_to_lower_case () {
    python -c "import re; import sys; print(re.sub(r'href=\"(#[^\"]*)\"', lambda m: m.group().lower(), sys.stdin.read()))"
}

# Sposta il numero del capitolo dai link href
remove_chapter_numbers_from_link () {
    sed 's/<h1 id=\"[0-9.]*-\(.*\)\">\(.*\)<\/h1>/<h1 id="\1">\2<\/h1>/' $1
}

# Preelaborazione dei file markdown per supportare i collegamenti interni e i design delle immagini
preprocess_markdown_to_support_md_to_pdf () {
    cat build/md/$1 | \
    replace_internal_markdown_links_with_in_headers_with_html_tags | \
    replace_internal_markdown_links_with_html_tags | \
    # Sezione Sed: Soluzione per risolvere il problema dei collegamenti a frammenti duplicati in 4.1.
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

# Crea file markdown divisi per capitoli
ls build/md | sort -n | while read x; do  preprocess_markdown_to_support_md_to_pdf $x >  build/epub/$x ; done

# Rimuove il file TOC
rm build/epub/document\>\>\>0-0.0_README.md

cd build/epub/

pandoc $VERSIONED_COVER_IMAGE_FILE_OPTION -o ../wstg-$VERSION.epub $VERSIONED_COVER_MARKDOWN_FILE ../second-cover-$VERSION.md *.md ../back-$VERSION.md \
    --table-of-contents --toc-depth=1 --metadata title="Web Security Testing Guide" --metadata subtitle="Version : $VERSION" --css="../../.github/epub/assets/epub-style.css"

