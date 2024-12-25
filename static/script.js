var elementsDown2 = document.getElementsByClassName("dropdown-content2");
var value = "";
var valuename = "";
// var textGuppe = [".docx", ".txt", ".odt", ".html", ".htm", ".doc", ".epub"];
var videoGruppe = ['.mp4', '.avi', '.mov', '.mkv', '.webm', '.flv', '.wmv', '.mpeg', '.mpg', '.ts', '.3gp',];
var audioGruppe = ['.mp3', '.wav', '.aac', '.flac', '.ogg', '.m4a', '.wma', '.ac3', '.amr','.mp4', '.avi', '.mov', '.mkv', '.webm', '.flv', '.wmv', '.mpeg', '.mpg', '.ts', '.3gp'];
var imageGruppe = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp'];
var tabelleGruppe = [".xls", ".xlsx", ".ods"];
var persentGruppe = [".ppt", ".pptx", ".odp"];
var pandocGruppe = [ ".md", ".rst", ".asciidoc", ".org", ".muse", ".textile", ".markua", ".txt2tags", ".djot",
  ".html", ".xhtml", ".html5", ".chunked-html",
  ".epub", ".fictionbook2",
  ".texinfo", ".haddock", ".roff-man", ".roff-ms", ".mdoc-man",
  ".latex", ".context",
  ".docbook", ".jats", ".bits", ".tei", ".opendocument", ".opml",
  ".bibtex", ".biblatex", ".csl-json", ".csl-yaml", ".ris", ".endnote",
  ".docx", ".rtf", ".odt",
  ".ipynb",
  ".icml", ".typst",
  ".mediawiki", ".dokuwiki", ".tikimediawiki", ".twiki", ".vimwiki", ".xwiki", ".zimwiki", ".jira-wiki", ".creole",
  ".beamer", ".slidy", ".revealjs", ".slideous", ".s5", ".dzslides",
  ".csv", ".tsv",
  ".ansi-text" ]
var convertFile = [
  ".md", ".rst", ".asciidoc", ".org", ".muse", ".textile", ".markua", ".txt2tags", ".djot",
  ".html", ".xhtml", ".html5", ".chunked-html",
  ".epub", ".fictionbook2",
  ".texinfo", ".haddock", ".roff-man", ".roff-ms", ".mdoc-man",
  ".latex", ".context",
  ".docbook", ".jats", ".bits", ".tei", ".opendocument", ".opml",
  ".bibtex", ".biblatex", ".csl-json", ".csl-yaml", ".ris", ".endnote",
  ".docx", ".rtf", ".odt",
  ".ipynb",
  ".icml", ".typst",
  ".mediawiki", ".dokuwiki", ".tikimediawiki", ".twiki", ".vimwiki", ".xwiki", ".zimwiki", ".jira-wiki", ".creole",
  ".beamer", ".slidy", ".revealjs", ".slideous", ".s5", ".dzslides",
  ".csv", ".tsv",
  ".ansi-text", ".xls", ".xlsx", ".ods", ".ppt", ".pptx", ".odp", '.mp4', '.avi', '.mov', '.mkv', '.webm', '.flv', '.wmv',
  '.mpeg', '.mpg', '.ts', '.3gp', '.mp3', '.wav', '.aac', '.flac', '.ogg', '.m4a', '.wma', '.ac3', '.amr', '.jpg', '.jpeg',
  '.png', '.gif', '.bmp', '.tiff', '.webp', '.mxf', '.vob', '.asf', '.dv', '.m3u8', '.mpd'
];




function filterFunction(dropdownClass) {
    const input = document.querySelector(`.${dropdownClass} .suche`);
    const filter = input.value.toLowerCase();
    const pElements = document.querySelectorAll(`.${dropdownClass} p`);

    // Alle p-Elemente zuerst wieder sichtbar machen
    pElements.forEach(function (item) {
        item.style.display = "flex";
    });

    // Dann nur die Elemente filtern, die der Suchabfrage entsprechen
    pElements.forEach(function (item) {
        const textValue = item.textContent.toLowerCase(); // Verwenden nur von textContent für bessere Kompatibilität
        if (textValue.indexOf(filter) == -1) {
            item.style.display = "none";
        } else {
            item.style.display = "flex";
        }
    });

    // Führe 'meineFunktion' nur aus, wenn das Suchfeld leer ist
    if (elementsDown2.length > 0 && window.getComputedStyle(elementsDown2[0]).display === "flex" && input.value.trim() === "") {
        meineFunktion();
    }
}

function setFileFunction(name, filename) {
  value = name;
  valuename = filename;
  console.log(value, valuename);

  if (
    elementsDown2.length > 0 &&
    window.getComputedStyle(elementsDown2[0]).display === "flex"
  ) {
    var dropbtn2 = document.getElementsByClassName("dropbtn2");
    if (dropbtn2.length > 0) {
      dropbtn2[0].innerHTML = valuename;
    }
  }

  return [value, valuename];
}

document.getElementById('fileInput').addEventListener('change', function(event) {
  const file = event.target.files[0];

  if (file) {
      const fileName = file.name; // Holt den Dateinamen
      const fileExtension = '.' + fileName.split('.').pop(); // Holt die Dateiendung mit Punkt

      console.log(`Dateiendung: ${fileExtension}`);
      meineFunktion(fileExtension); // Funktion zum Steuern der Anzeige aufrufen
  } else {
      console.log('Keine Datei ausgewählt.');
  }
});

function meineFunktion(name) {
  var elementsPandoc = document.getElementsByClassName("pandoc");
  var elementsExel = document.getElementsByClassName("exel");
  var elementsPPT = document.getElementsByClassName("ppt");
  var elementsVideo = document.getElementsByClassName("video");
  var elementsAudio = document.getElementsByClassName("audio");
  var elementsImage = document.getElementsByClassName("image");

 

  if (pandocGruppe.includes(name)) {
    for (var i = 0; i < elementsExel.length; i++) {
      elementsExel[i].style.display = "none"; 
    }
    for (var i = 0; i < elementsPPT.length; i++) {
      elementsPPT[i].style.display = "none";
    }
    for (var i = 0; i < elementsVideo.length; i++) {
      elementsVideo[i].style.display = "none";
    }
    for (var i = 0; i < elementsAudio.length; i++) {
      elementsAudio[i].style.display = "none";
    }
    for (var i = 0; i < elementsImage.length; i++) {
      elementsImage[i].style.display = "none";
    }
  } else if (tabelleGruppe.includes(name)) {
    for (var i = 0; i < elementsPPT.length; i++) {
      elementsPPT[i].style.display = "none";
    }
    for (var i = 0; i < elementsPandoc.length; i++) {
      elementsPandoc[i].style.display = "none";
    }
    for (var i = 0; i < elementsVideo.length; i++) {
      elementsVideo[i].style.display = "none";
    }
    for (var i = 0; i < elementsAudio.length; i++) {
      elementsAudio[i].style.display = "none";
    }
    for (var i = 0; i < elementsImage.length; i++) {
      elementsImage[i].style.display = "none";
    }
  } else if (persentGruppe.includes(name)) {
    for (var i = 0; i < elementsPandoc.length; i++) {
      elementsPandoc[i].style.display = "none"; 
    }
    for (var i = 0; i < elementsExel.length; i++) {
      elementsExel[i].style.display = "none";
    }
    for (var i = 0; i < elementsVideo.length; i++) {
      elementsVideo[i].style.display = "none";
    }
    for (var i = 0; i < elementsAudio.length; i++) {
      elementsAudio[i].style.display = "none";
    }
    for (var i = 0; i < elementsImage.length; i++) {
      elementsImage[i].style.display = "none";
    }
  } else if (videoGruppe.includes(name)) {
    for (var i = 0; i < elementsPandoc.length; i++) {
      elementsPandoc[i].style.display = "none"; 
    }
    for (var i = 0; i < elementsExel.length; i++) {
      elementsExel[i].style.display = "none";
    }
    for (var i = 0; i < elementsPPT.length; i++) {
      elementsPPT[i].style.display = "none";
    }
//    for (var i = 0; i < elementsAudio.length; i++) {
//      elementsAudio[i].style.display = "none";
//   }
    for (var i = 0; i < elementsImage.length; i++) {
      elementsImage[i].style.display = "none";
    }
  } else if (audioGruppe.includes(name)) {
    for (var i = 0; i < elementsPandoc.length; i++) {
      elementsPandoc[i].style.display = "none"; 
    }
    for (var i = 0; i < elementsExel.length; i++) {
      elementsExel[i].style.display = "none";
    }
    for (var i = 0; i < elementsPPT.length; i++) {
      elementsPPT[i].style.display = "none";
    }
    for (var i = 0; i < elementsVideo.length; i++) {
      elementsVideo[i].style.display = "none";
    }
    for (var i = 0; i < elementsImage.length; i++) {
      elementsImage[i].style.display = "none";
    }
  } else if (imageGruppe.includes(name)) {
    for (var i = 0; i < elementsPandoc.length; i++) {
      elementsPandoc[i].style.display = "none"; 
    }
    for (var i = 0; i < elementsExel.length; i++) {
      elementsExel[i].style.display = "none";
    }
    for (var i = 0; i < elementsPPT.length; i++) {
      elementsPPT[i].style.display = "none";
    }
    for (var i = 0; i < elementsVideo.length; i++) {
      elementsVideo[i].style.display = "none";
    }
    for (var i = 0; i < elementsAudio.length; i++) {
      elementsAudio[i].style.display = "none";
    }
  }
}



function sendData() {
  fetch('/empfange_daten', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ daten: valuename })
  })
  .then(response => {
    if (!response.ok) {
      throw new Error('Netzwerkantwort war nicht ok');
    }
    return response.json();
  })
  .then(data => {
    console.log('Erfolg:', data);
    // Hier können Sie das Formular manuell absenden
    document.querySelector('form').submit();
  })
  .catch((error) => {
    console.error('Fehler:', error);
    // Hier können Sie dem Benutzer eine Fehlermeldung anzeigen
  });
}
document.querySelectorAll('.dropdown2').forEach(dropdown => {
  dropdown.addEventListener('mouseenter', () => {
    const dropdownContent = dropdown.querySelector('.dropdown-content2');
    dropdownContent.style.maxHeight = '300px';
    dropdownContent.style.opacity = '1';
    // Breite wird jetzt durch CSS-Transition geregelt
  });

  dropdown.addEventListener('mouseleave', () => {
    const dropdownContent = dropdown.querySelector('.dropdown-content2');
    dropdownContent.style.maxHeight = '0';
    dropdownContent.style.opacity = '0';
    // Breite wird jetzt durch CSS-Transition geregelt
  });
});




function updateFileName() {
  const fileInput = document.getElementById('fileInput');
  const fileLabel = document.getElementById('fileLabel');
  const errorElement = document.getElementById('error');
  
  if (fileInput.files.length > 0) {
    const fileName = fileInput.files[0].name;
    const fileExtension = '.' + fileName.split('.').pop().toLowerCase(); // Kleinbuchstaben für Konsistenz

    if (convertFile.includes(fileExtension)) {
      // Kein Fehler, Dateiname anzeigen
      errorElement.innerHTML = '';
      fileLabel.textContent = fileName;
    } else {
      // Fehler: Ungültiges Dateiformat
      errorElement.innerHTML = 'Invalid file format. More details: <a href="https://pandoc.org/" target="_blank">pandoc</a>';
      fileLabel.textContent = 'Datei auswählen'; // Standard-Text zurücksetzen
    }
  } else {
    // Keine Datei ausgewählt
    fileLabel.textContent = 'Datei auswählen';
    errorElement.innerHTML = ''; // Kein Fehler anzeigen
  }
}


