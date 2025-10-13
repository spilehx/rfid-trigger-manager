const UPDATE_INTERVAL_TIME = 2000;

var cardTable = {};
var actions = [];
var configData = {};
var logs = [];
var backendConnected = true;

(function () {
  window.addEventListener("load", function () {
    onPageLoaded();
  });
})();

function onPageLoaded() {
  setElements();
  setupChooseDeviceModal();
  setupVerboseLoggingCheckbox();
  loadData();
  startAutoUpdate();
}



function setupChooseDeviceModal() {
  const btn = document.getElementById("chooseDeviceBtn");
  if(!btn) return;

  const modal = document.getElementById("deviceModal");
  const select = document.getElementById("deviceSelect");
  const ok = document.getElementById("deviceModalOk");
  const cancel = document.getElementById("deviceModalCancel");

  btn.addEventListener("click", () => {
    // const options = Array.isArray(configData?.availableDevices) ? configData.availableDevices : [];

    // console.log(configData.avalibleDevices);
    onOpenChooseDeviceModal(modal, select, configData.avalibleDevices);
  });

  ok.addEventListener("click", () => onChooseDeviceModalOkClick(modal, select));
  cancel.addEventListener("click", () => onChooseDeviceModalCloseClick(modal));

  modal.addEventListener("click", e => {
    if(e.target === modal || e.target.classList.contains("modal-backdrop")) closeModal(modal);
  });
  window.addEventListener("keydown", e => {
    if(!modal.classList.contains("hidden") && e.key === "Escape"){
      e.preventDefault();
      onChooseDeviceModalCloseClick(modal);
    }
  });
}

function onOpenChooseDeviceModal(modal, select, options = []) {
  const opts = options.length ? options : ["Device A","Device B","Device C"];
  select.innerHTML = opts.map(v => `<option value="${v}">${v}</option>`).join("");
  modal.classList.remove("hidden");
  modal.setAttribute("aria-hidden","false");
  select.focus();
}

function onChooseDeviceModalOkClick(modal, select) {
  const chosen = select.value;
  console.log("chosen "+chosen);
  configData.deviceID = chosen;
  // setDeviceIdField(chosen);
  postConfigData();
  onChooseDeviceModalCloseClick(modal);
}

function onChooseDeviceModalCloseClick(modal) {
  modal.classList.add("hidden");
  modal.setAttribute("aria-hidden","true");
}


function setBackendConnectedState(state) {
  if (backendConnected != state) {
    backendConnected = state;
    if (backendConnected == true) {
      setStatus("Backend connected", "");
      addLogLine("INFO: Backend connected");
    } else {
      setStatus("Cant load data! Is backend running?", "error");
      addLogLine("ERROR: Backend not found");
    }
  }
}

function showBackendReconnectState() {
  setStatus("Retrying Connection", "error");
  addLogLine("INFO: Retrying backend connection");
}

function setElements() {
  cardTable = document.getElementById("cardsBody");
}

function startAutoUpdate() {
  var intervalId = setInterval(() => {
    if (backendConnected == false) {
      showBackendReconnectState();
    }

    loadData();
  }, UPDATE_INTERVAL_TIME);
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
      setBackendConnectedState(true);
      onConfigDataLoaded(data);
    })
    .catch((error) => {
      setBackendConnectedState(false);
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
  actions = Array.isArray(configData?.avalibleCardActions) ? configData.avalibleCardActions : [];
  setDeviceIdField(configData["deviceID"]);
  updateLastUpdatedField();
  updateCardsTable();
  updateVerboseLoggingCheckbox();
}

function setupVerboseLoggingCheckbox() {
  var verboseLoggingCheckbox = document.getElementById("verboseLoggingCheckbox");
  verboseLoggingCheckbox.addEventListener("change", (e) => {
    configData.verboseLogging = e.target.checked;
    postConfigData();
  });
}

function updateVerboseLoggingCheckbox() {
  var verboseLoggingCheckbox = document.getElementById("verboseLoggingCheckbox");
  verboseLoggingCheckbox.checked = configData.verboseLogging;
}

function updateLogs(newLogs) {
  var newLogArray = newLogs.split("\n");

  if (newLogArray != logs) {
    const newLogs = newLogArray.filter((item) => !logs.includes(item));

    while (newLogs.length > 0) {
      let line = newLogs.shift();
      logs.push(line);
      addLogLine(line);
    }
  }
}

function addLogLine(value) {
  var terminalEl = document.getElementById("terminal");

  const newLine = document.createElement("p");

  if (value.indexOf("DEBUG:") !== -1) {
    newLine.classList.add("log_debug");
  }

  if (value.indexOf("ERROR:") !== -1) {
    newLine.classList.add("log_error");
  }

  if (value.indexOf("INFO:") !== -1) {
    newLine.classList.add("log_info");
  }

  if (value.indexOf("WARN:") !== -1) {
    newLine.classList.add("log_warn");
  }

  newLine.textContent = value;
  terminalEl.appendChild(newLine);

  // Limit lines
  while (terminalEl.children.length > 70) {
    terminalEl.removeChild(terminalEl.firstChild);
  }

  // Auto-scroll to bottom
  terminalEl.scrollTop = terminal.scrollHeight;
}

function updateCardsTable() {
  for (i in configData.cards) {
    var card = configData.cards[i];

    if (getCardRow(card) == null) {
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

      if (document.activeElement == inputChild) {
        // dont update edit in progress!
        return;
      }

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

  // Helper to get current index of this card inside configData.cards
  const getIdx = () => (Array.isArray(configData?.cards) ? configData.cards.findIndex((c) => String(c.id) === String(card.id)) : -1);

  const idx = getIdx();

  if (idx !== -1) {
    // console.log("UPDATE CARD "+idx+"  "+configData.cards[idx][fieldName]);
    configData.cards[idx][fieldName] = newValue;
    postConfigData();
  }
}

function postConfigData() {
  if (!configData) return;
  setStatus("Saving…", "");
  fetch("./setconfig", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(configData),
  })
    .then((res) => {
      if (!res.ok) throw new Error("Failed to save config");
      setStatus("Saved ✓", "success");
    })
    .catch((err) => {
      console.error("Error saving config:", err);
      setStatus("Save failed", "error");
    });
}

function setStatus(msg, type) {
  const el = document.getElementById("statusBanner");
  if (!el) return;
  el.textContent = msg || "";
  el.className = "small status " + (type || "");
  if (msg) {
    el.style.display = "inline";
    clearTimeout(window._statusTimer);
    window._statusTimer = setTimeout(() => {
      el.style.display = "none";
    }, 2000);
  } else {
    el.style.display = "none";
  }
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
