var elementsDown1 = document.getElementsByClassName("dropdown-content1");
var elementsDown2 = document.getElementsByClassName("dropdown-content2");

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
        const textValue = item.textContent || item.innerText;
        if (textValue.toLowerCase().indexOf(filter) == -1) {
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
    elementsDown1.length > 0 &&
    window.getComputedStyle(elementsDown1[0]).display === "flex"
  ) {
    var dropbtn1 = document.getElementsByClassName("dropbtn1");
    if (dropbtn1.length > 0) {
      dropbtn1[0].innerHTML = valuename;
    }
  }

  if (
    elementsDown2.length > 0 &&
    window.getComputedStyle(elementsDown2[0]).display === "flex"
  ) {
    var dropbtn2 = document.getElementsByClassName("dropbtn2");
    if (dropbtn2.length > 0) {
      dropbtn2[0].innerHTML = valuename;
    }
  }

  return value;
}

function meineFunktion() {
    var elementsText = document.getElementsByClassName("text");
    var elementsAudio = document.getElementsByClassName("audio");
    var elementsPPT = document.getElementsByClassName("ppt");
    var elementsBild = document.getElementsByClassName("bild");
    
    // Verstecke oder zeige Text-Elemente basierend auf dem globalen Wert
    for (var i = 0; i < elementsText.length; i++) {
      elementsText[i].style.display = value == "audio" || value == "ppt" || value == "bild" ? "none" : "flex";
    }
    
    // Verstecke oder zeige Audio-Elemente basierend auf dem globalen Wert
    for (var i = 0; i < elementsAudio.length; i++) {
      elementsAudio[i].style.display = value == "text" || value == "ppt" || value == "bild" ? "none" : "flex";
    }
    
    // Verstecke oder zeige PPT-Elemente basierend auf dem globalen Wert
    for (var i = 0; i < elementsPPT.length; i++) {
      elementsPPT[i].style.display = value == "text" || value == "audio" || value == "bild" ? "none" : "flex";
    }
    
    // Verstecke oder zeige Bild-Elemente basierend auf dem globalen Wert
    for (var i = 0; i < elementsBild.length; i++) {
      elementsBild[i].style.display = value == "text" || value == "audio" || value == "ppt" ? "none" : "flex";
    }
    
}
