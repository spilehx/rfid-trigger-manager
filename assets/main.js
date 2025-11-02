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
  setupCacheModal();
  setupVerboseLoggingCheckbox();
  loadData();
  startAutoUpdate();
}

function setupCacheModal() {
  const btn = document.getElementById("cacheModalBtn");
  if (!btn) return;

  const modal = document.getElementById("cacheModal");
  // const select = document.getElementById("deviceSelect");
  const ok = document.getElementById("cacheModalOk");
   ok.addEventListener("click", () => onCacheModalCloseClick(modal));
  // const cancel = document.getElementById("cacheModalCancel");

  btn.addEventListener("click", () => {
    onOpenCacheModal(modal, configData.avalibleDevices);
  });
}

function onOpenCacheModal(modal) {

  const list = document.querySelector("#cacheModal .modal-item-list");
  list.innerHTML = '';

  for (i in configData.cards) {
    var card = configData.cards[i];
    if (card.action == "YTPlayListAction") {
      addCacheItem(card);
    }
  }
  modal.classList.remove("hidden");
  modal.setAttribute("aria-hidden", "false");
}


function onCacheModalCloseClick(modal) {
  modal.classList.add("hidden");
  modal.setAttribute("aria-hidden", "true");
}

function addCacheItem(card) {
  var title = card.name;
  var id = card.id;

  // Find the list container
  const list = document.querySelector("#cacheModal .modal-item-list");
  if (!list) return console.error("Modal list not found.");

  // Create the <li> element
  const li = document.createElement("li");
  li.classList.add("modal-item");

  // Create the info container
  const infoDiv = document.createElement("div");
  infoDiv.classList.add("item-info");

  const titleSpan = document.createElement("span");
  titleSpan.classList.add("item-title");
  titleSpan.textContent = title;

  // Create the action button
  const button = document.createElement("button");
  button.classList.add("item-action");
  button.textContent = "⟳";

  button.addEventListener("click", () => {
    button.disabled = true;
    button.textContent = "✓";
    onCacheButtonClicked(card.id);
  });

  infoDiv.appendChild(titleSpan);
  infoDiv.appendChild(button);

  li.appendChild(infoDiv);
  list.appendChild(li);
}


function onCacheButtonClicked(cardId){
  console.log(cardId);

  const url = `${window.location.origin}/triggerytcache?cardid=${cardId}`;
  fetch(url, { method: "GET" })
    .then((response) => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response.text();
    })
    .then((data) => {
      console.log("Trigger response:", data);
    })
    .catch((error) => {
      console.error("Trigger request failed:", error);
    });
}






function setupChooseDeviceModal() {
  const btn = document.getElementById("chooseDeviceBtn");
  if (!btn) return;

  const modal = document.getElementById("deviceModal");
  const select = document.getElementById("deviceSelect");
  const ok = document.getElementById("deviceModalOk");
  const cancel = document.getElementById("deviceModalCancel");

  btn.addEventListener("click", () => {
    onOpenChooseDeviceModal(modal, select, configData.avalibleDevices);
  });

  ok.addEventListener("click", () => onChooseDeviceModalOkClick(modal, select));
  cancel.addEventListener("click", () => onChooseDeviceModalCloseClick(modal));

  modal.addEventListener("click", (e) => {
    if (e.target === modal || e.target.classList.contains("modal-backdrop")) onChooseDeviceModalCloseClick(modal);
  });
  window.addEventListener("keydown", (e) => {
    if (!modal.classList.contains("hidden") && e.key === "Escape") {
      e.preventDefault();
      onChooseDeviceModalCloseClick(modal);
    }
  });
}

function onOpenChooseDeviceModal(modal, select, options = []) {
  const opts = options.length ? options : ["No devices detected"];

  // enabled state if there are devices
  var choiceDisabled = options.length == 0;
  document.getElementById("deviceModalOk").hidden = choiceDisabled;
  select.disabled = choiceDisabled;

  select.innerHTML = opts.map((v) => `<option value="${v}">${v}</option>`).join("");
  modal.classList.remove("hidden");
  modal.setAttribute("aria-hidden", "false");
  select.focus();
}

function onChooseDeviceModalOkClick(modal, select) {
  const chosen = select.value;
  console.log("chosen " + chosen);
  configData.deviceID = chosen;
  postConfigData();
  onChooseDeviceModalCloseClick(modal);
}

function onChooseDeviceModalCloseClick(modal) {
  modal.classList.add("hidden");
  modal.setAttribute("aria-hidden", "true");
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
    reloadNowPlayingImg();
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
    if (type == "button") {
      if (fieldName == "trigger") {
        tdEl.appendChild(getTriggerButton(card));
      } else if (fieldName == "image") {
        tdEl.appendChild(getUploadImageButton(card));
      }
    } else {
      tdEl.textContent = fieldValue;
    }
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
  row.appendChild(createCell(card, "trigger", "button", false));
  row.appendChild(createCell(card, "image", "button", false));
  return row;
}

function getTriggerButton(card) {
  var btn = document.createElement("button");
  btn.style.width = "35px";
  btn.style.height = "35px";
  btn.style.border = "none";
  btn.style.cursor = "pointer";
  btn.style.background = "transparent";
  btn.style.fontSize = "18px";
  btn.textContent = "▶️";

  btn.addEventListener("click", () => {
    sendTriggerRequest(card.id);
  });

  return btn;
}

function getUploadImageButton(card) {
  var btn = document.createElement("button");
  btn.style.width = "35px";
  btn.style.height = "35px";
  btn.style.border = "none";
  btn.style.cursor = "pointer";
  btn.style.background = "transparent";
  btn.style.fontSize = "18px";
  btn.textContent = "🖼️";

  btn.addEventListener("click", () => {
    onClickImageUploadRequest(card.id);
  });

  return btn;
}

function onClickImageUploadRequest(cardId) {
  console.log("onImageUploadRequest");
  // Create a hidden input element
  const input = document.createElement("input");
  input.type = "file";
  input.accept = "image/*"; // restricts to image files
  input.style.display = "none";

  // Listen for when the user selects a file
  input.addEventListener("change", (event) => {
    const file = event.target.files[0];
    if (file) {
      onUploadImageRequest(file, cardId);
    }
  });

  // Trigger the file picker
  document.body.appendChild(input);
  input.click();

  // Clean up afterward
  input.remove();
}

function onUploadImageRequest(file, cardId) {
  const url = `${window.location.origin}/uploadimage`;

  // Helper to convert non-JPG images to JPG
  function convertToJpg(file) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      const reader = new FileReader();

      reader.onload = function (e) {
        img.src = e.target.result;
      };

      img.onload = function () {
        const canvas = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;

        const ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);

        // Convert to JPG (quality 0.9)
        canvas.toBlob(
          (blob) => {
            if (!blob) {
              reject(new Error("Conversion to JPG failed"));
              return;
            }
            resolve(new File([blob], replaceExtension(file.name, "jpg"), { type: "image/jpeg" }));
          },
          "image/jpeg",
          0.9
        );
      };

      img.onerror = reject;
      reader.onerror = reject;

      reader.readAsDataURL(file);
    });
  }

  function replaceExtension(filename, newExt) {
    return filename.replace(/\.[^/.]+$/, "") + "." + newExt;
  }

  async function processAndUpload() {
    try {
      let processedFile = file;

      // Convert if not already JPG/JPEG
      if (!file.type.includes("jpeg") && !file.type.includes("jpg")) {
        processedFile = await convertToJpg(file);
      }

      const reader = new FileReader();

      reader.onload = function () {
        const base64Data = reader.result.split(",")[1];
        const fileExtension = processedFile.name.split(".").pop();

        const payload = {
          cardId: cardId,
          file: base64Data,
          fileExtension: fileExtension,
        };

        fetch(url, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(payload),
        })
          .then((response) => {
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            return response.text();
          })
          .then((data) => {
            console.log("Upload response:", data);
          })
          .catch((error) => {
            console.error("Upload request failed:", error);
          });
      };

      reader.onerror = (err) => console.error("Error reading file:", err);
      reader.readAsDataURL(processedFile);
    } catch (error) {
      console.error("File processing failed:", error);
    }
  }

  processAndUpload();
}

function sendTriggerRequest(cardId) {
  const url = `${window.location.origin}/trigger?cardid=${cardId}`;
  fetch(url, { method: "GET" })
    .then((response) => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response.text();
    })
    .then((data) => {
      console.log("Trigger response:", data);
    })
    .catch((error) => {
      console.error("Trigger request failed:", error);
    });
}

function setDeviceIdField(value) {
  document.getElementById("deviceId").textContent = value;
}

function updateLastUpdatedField() {
  document.getElementById("lastUpdated").textContent = new Date().toLocaleString();
}

function reloadNowPlayingImg() {
  const img = document.getElementById("nowplayingimg");
  if (img) {
    const src = img.src.split("?")[0]; // remove any existing cache-busting query
    img.src = `${src}?t=${new Date().getTime()}`; // add timestamp to force reload
  }
}

// async function openCardModal() {
//   const cards = await getCards();     // existing/placeholder data source
//   renderCardList(cards);
//   const m = document.getElementById('cardModal');
//   m.classList.remove('hidden');
//   m.setAttribute('aria-hidden','false');
// }

// function renderCardList(cards) {
//   const ul = document.getElementById('cardList');
//   ul.innerHTML = '';
//   cards.forEach(c => {
//     const li = document.createElement('li');
//     li.className = 'card-row';
//     li.innerHTML = `<span class="mono">${c.id}</span> — ${c.name || '(unnamed)'} ${c.enabled ? '' : '<em>(disabled)</em>'}`;
//     ul.appendChild(li);
//   });
// }
