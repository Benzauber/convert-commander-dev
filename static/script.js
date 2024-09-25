var elementsDown2 = document.getElementsByClassName("dropdown-content2");
var value = "";
var valuename = "";
var textGuppe = [".docx", ".txt", ".odt", ".html", ".htm", ".doc"];
var tabelleGruppe = [".xls", ".xlsx", ".ods"];
var persentGruppe = [".ppt", ".pptx", ".odp"];

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
  var elementsText = document.getElementsByClassName("text");
  var elementsExel = document.getElementsByClassName("exel");
  var elementsPPT = document.getElementsByClassName("ppt");

  if (textGuppe.includes(name)) {
    for (var i = 0; i < elementsExel.length; i++) {
      elementsExel[i].style.display = "none"; 
    }
    for (var i = 0; i < elementsPPT.length; i++) {
      elementsPPT[i].style.display = "none";
    }
  } else if (tabelleGruppe.includes(name)) {
    for (var i = 0; i < elementsPPT.length; i++) {
      elementsPPT[i].style.display = "none";
    }
    for (var i = 0; i < elementsText.length; i++) {
      elementsText[i].style.display = "none";
    }
  } else if (persentGruppe.includes(name)) {
    for (var i = 0; i < elementsText.length; i++) {
      elementsText[i].style.display = "none"; 
    }
    for (var i = 0; i < elementsExel.length; i++) {
      elementsExel[i].style.display = "none";
    }
  }
}

function sendData() {
  document.getElementById("submitButton").value = "Wird gesendet...";
  fetch('/empfange_daten', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    body: JSON.stringify({ daten: valuename })
  })
  .then(response => response.json())
  .then(data => console.log('Erfolg:', data))
  .catch((error) => console.error('Fehler:', error));
  console.log(value);
}

function updateFileName() {
  const fileInput = document.getElementById('fileInput');
  const fileLabel = document.getElementById('fileLabel');
  
  if (fileInput.files.length > 0) {
      fileLabel.textContent = fileInput.files[0].name;
  } else {
      fileLabel.textContent = 'Datei auswählen';
  }
}
