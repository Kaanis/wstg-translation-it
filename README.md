# OWASP Web Security Testing Guide

[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/OWASP/wstg/issues)
[![OWASP Flagship](https://img.shields.io/badge/owasp-flagship-brightgreen.svg)](https://owasp.org/projects/)
[![Twitter Follow](https://img.shields.io/twitter/follow/owasp_wstg?style=social)](https://twitter.com/owasp_wstg)

[![Creative Commons License](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-sa/4.0/ "CC BY-SA 4.0")

Benvenuti nella traduzione italiana del repository ufficiale della Open Web Application Security Project® (OWASP®) Web Security Testing Guide (WSTG). La WSTG è una guida completa per testare la sicurezza delle applicazioni e dei servizi web. Creata grazie alla collaborazione di professionisti della sicurezza e di volontari, la WSTG fornisce un quadro delle migliori pratiche utilizzate dai penetration tester e dalle organizzazioni di tutto il mondo.

Attualmente è in lavorazione la versione 5.0. È possibile [leggere l'ultimo documento qui su Github](https://github.com/OWASP/wstg/tree/master/document).

A questo indirizzo invece l'ultima versione stabile, [la 4.2](https://github.com/OWASP/wstg/releases/tag/v4.2). Disponibile anche [online](https://owasp.org/www-project-web-security-testing-guide/v42/).

- [Come fare riferimento agli scenari WSTG](#how-to-reference-wstg-scenarios)
    - [Linking](#linking)
- [Contributi, richieste di funzioni e feedback](#contributions-feature-requests-and-feedback)
- [Chatta con noi](#chat-with-us)
- [Responsabili del progetto](#project-leaders)
- [Team di base](#core-team)
- [Traduzioni](#translations)

## Come fare riferimento agli scenari WSTG

Ogni scenario ha un identificatore nel formato WSTG `WSTG-<category>-<number>`,  dove: 'category' è una stringa di 4 caratteri maiuscoli che identifica il tipo di test o di vulnerabilità e 'number' è un valore numerico con riempimento a zero da 01 a 99. Ad esempio:`WSTG-INFO-02` è il secondo test di Information Gathering.

Gli identificatori possono cambiare da una versione all'altra. Pertanto, è preferibile che altri documenti, report o strumenti utilizzino il formato: `WSTG-<version>-<category>-<number>`,dove: 'version' è il tag della versione senza punteggiatura. Ad esempio: `WSTG-v42-INFO-02` si intende specificamente il secondo test di Information Gathering della versione 4.2.

Se si utilizzano identificatori senza includere l'elemento `<version>` si deve ritenere che si riferiscano al contenuto più recente della Web Security Testing Guide. Ovviamente, man mano che la guida cresce e cambia, questo diventa problematico, ed è per questo che gli autori o gli sviluppatori dovrebbero includere l'elemento version.

### Linking

I collegamenti agli scenari della Guida devono essere effettuati utilizzando link con versione, non `stable` o `latest`,che cambierà sicuramente con il tempo. Tuttavia, è intenzione del team di progetto che i link versionati non cambino. Ad esempio: `https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/02-Fingerprint_Web_Server.html`.  Nota: l'elemento  `v42` si riferisce alla versione 4.2.

## Contributi, richieste di funzioni e feedback

Accettiamo attivamente nuovi collaboratori! Per iniziare, leggi la [guida ai contributi](CONTRIBUTING.md).

È la prima volta che partecipi? Ecco i [suggerimenti di GitHub per chi contribuisce per la prima volta](https://github.com/OWASP/wstg/contribute) a questo repository.

Questo progetto è possibile solo grazie al lavoro di molti volontari. Tutti sono incoraggiati ad aiutare. Ecco alcuni modi per aiutare:

- Leggere i contenuti attuali e aiutare a correggere eventuali errori di ortografia o grammatica.
- Aiutare con le iniziative di [traduzione](CONTRIBUTING.md#translation).
- Scegliere un problema esistente e inviare una richiesta pull per risolverlo.
- Aprire un nuovo problema per segnalare un'opportunità di miglioramento.

Per imparare a contribuire con successo, leggere la [guida ai contributi](CONTRIBUTING.md).

I contributori di successo appaiono nell'[elenco degli autori, revisori o redattori del progetto](document/1-Frontispiece/README.md).

## Chatta con noi

È facile trovare OWASP su Slack:

1. Unitevi al gruppo OWASP di Slack con questo [link di invito](https://owasp.org/slack/invite).
2. Unitevi al [canale, #testing-guide](https://app.slack.com/client/T04T40NHX/CJ2QDHLRJ).

Sentitevi liberi di fare domande, suggerire idee o condividere le vostre migliori idee.

Potete scrivere su Twitter a [@owasp_wstg](https://twitter.com/owasp_wstg).

Potete anche unirvi al [Google Group](https://groups.google.com/a/owasp.org/forum/#!forum/testing-guide-project).

## Responsabili del progetto

- [Rick Mitchell](https://github.com/kingthorin)
- [Elie Saad](https://github.com/ThunderSon)

## Team di base

- [Rejah Rehim](https://github.com/rejahrehim)
- [Victoria Drake](https://github.com/victoriadrake)

## Traduzioni

- [Portoghese-BR](https://github.com/doverh/wstg-translations-pt)
- [Russo](https://github.com/andrettv/WSTG/tree/master/WSTG-ru)
- [Francese](https://github.com/clallier94/wstg-translation-fr)
- [Persiano (Farsi)](https://github.com/whoismh11/owasp-wstg-fa)

---

Open Web Application Security Project e OWASP sono marchi registrati della OWASP Foundation, Inc.
