
var cardTable = {};

var actions = [];
var configData = {};
var logs = [];

(function () {
  window.addEventListener("load", function () {
    onPageLoaded();
  });
})();

function onPageLoaded() {
  console.log("page loaded");
  setElements();
  loadData();
  startAutoUpdate();
}

function setElements() {
  cardTable = document.getElementById("cardsBody");
}

function startAutoUpdate() {
  var intervalId = setInterval(() => {
    loadData();
  }, 1000);
}

function loadData() {
  fetch("./config")
    .then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok " + response.status + " " + response.statusText);
      }
      return response.json();
    })
    .then((data) => {
      onConfigDataLoaded(data);
    })
    .catch((error) => {
      //   console.error("Error loading config data:", error);
    });
}

function onConfigDataLoaded(data) {
  if (JSON.stringify(data) != JSON.stringify(configData)) {
    configData = data.config;
    updateLogs(data.logs);
    updatePage();
  }
}

function updatePage() {
  console.log("updatepage");
  actions = Array.isArray(configData?.avalibleCardActions) ? configData.avalibleCardActions : [];
  setDeviceIdField(configData["deviceID"]);

  updateLastUpdatedField();
  updateCardsTable();
}

function updateLogs(newLogs) {
  var newLogArray = newLogs.split("\n");

  if (newLogArray != logs) {
    const newLogs = newLogArray.filter((item) => !logs.includes(item));

    while (newLogs.length > 0) {
      let line = newLogs.shift(); // remove and return the last element
      logs.push(line);
      addLogLine(line);
    }
  }

  //   logs = Array.isArray(configData?.avalibleCardActions) ? configData.avalibleCardActions : [];

  // console.log(newLogs);
}

function addLogLine(value) {
  var terminalEl = document.getElementById("terminal");

  const newLine = document.createElement("p");
  newLine.textContent = value;
  terminalEl.appendChild(newLine);

  // Limit lines
  while (terminalEl.children.length > 70) {
    console.log("Auto remove");
    terminalEl.removeChild(terminalEl.firstChild);
  }

  // Auto-scroll to bottom
  terminalEl.scrollTop = terminal.scrollHeight;
}

function test() {
  onConfigDataLoaded();
  setDeviceIdField("hello");
  updateLastUpdatedField();

  addLogLine("test");
  addLogLine("dddd");
  addLogLine("ffddd");
  addLogLine("sdsdsdsd");

  updateCardsTable();
  updateCardsTable();
}

function updateCardsTable() {
  for (i in configData.cards) {
    var card = configData.cards[i];

    if (getCardRow(card) == null) {
      console.log("card row not found creating new one");

      cardTable.appendChild(createNewRow(card));
    } else {
      updateCardRow(card);
    }
  }
}

function getCardRow(card) {
  let row = Array.from(cardTable.querySelectorAll("tr")).find((r) => r.dataset && r.dataset.cardId === String(card.id));
  return row;
}

function updateCardRow(card) {
  for (let key in card) {
    if (card.hasOwnProperty(key)) {
      updateCardRowValue(card, key, card[key]);
    }
  }
}

function updateCardRowValue(card, field, newValue) {
  var row = getCardRow(card);
  const cellEl = row.querySelector("#" + field);

  if (cellEl != null) {
    if (cellEl.querySelector("#inputChild")) {
      // input field
      var inputChild = cellEl.querySelector("#inputChild");
      if (inputChild.type == "checkbox") {
        if (inputChild.checked != newValue) {
          inputChild.checked = newValue;
        }
      } else if (inputChild.type == "select") {
        if (inputChild.value != newValue) {
          inputChild.value = newValue;
        }
      } else {
        if (inputChild.value != newValue) {
          inputChild.value = newValue;
        }
      }
    } else {
      // not an input field
      if (cellEl.textContent != newValue) {
        cellEl.textContent = newValue;
      }
    }
  }
}

function onCardValueEdited(card, fieldName, newValue) {
  console.log("onCardValueEdited " + card.id + " " + fieldName + " " + newValue);
}

function createCell(card, fieldName, type, editable, selectOptions) {
  const tdEl = document.createElement("td");
  const fieldValue = card[fieldName];

  if (editable == true) {
    var inputEl = {};
    inputEl.type = type;

    if (type == "checkbox") {
      inputEl = document.createElement("input");
      inputEl.checked = fieldValue;
    } else if (type == "select") {
      inputEl = document.createElement("select");

      selectOptions.forEach((option) => {
        const opt = document.createElement("option");
        opt.value = option;
        opt.textContent = option;
        inputEl.appendChild(opt);
      });
      inputEl.value = fieldValue;
    } else {
      inputEl = document.createElement("input");
      inputEl.value = fieldValue;
    }

    inputEl.addEventListener("change", (e) => {
      // use the checked field if its a check box else use the value field
      const newValue = e.target.type === "checkbox" ? e.target.checked : e.target.value;
      onCardValueEdited(card, fieldName, newValue);
    });

    inputEl.type = type;
    inputEl.id = "inputChild";
    tdEl.appendChild(inputEl);
  } else {
    tdEl.textContent = fieldValue;
  }

  tdEl.id = fieldName;
  return tdEl;
}

function createNewRow(card) {
  const row = document.createElement("tr");
  row.dataset.cardId = String(card.id);

  // Build full set of cells to mirror updatePage rendering
  const tdId = document.createElement("td");
  tdId.className = "mono";
  tdId.textContent = card.id ?? "";
  row.appendChild(tdId);

  row.appendChild(createCell(card, "name", "text", true));
  row.appendChild(createCell(card, "enabled", "checkbox", true));
  row.appendChild(createCell(card, "active", "text", false));
  row.appendChild(createCell(card, "current", "text", false));
  row.appendChild(createCell(card, "command", "text", true));
  row.appendChild(createCell(card, "action", "select", true, actions));
  row.appendChild(createCell(card, "actionState", "text", false));

  return row;
}

function setDeviceIdField(value) {
  document.getElementById("deviceId").textContent = value;
}

function updateLastUpdatedField() {
  document.getElementById("lastUpdated").textContent = new Date().toLocaleString();
}
