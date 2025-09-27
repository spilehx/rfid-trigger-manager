 let configData = null;
        let intervalId = null;

        function pageLoaded() {
            console.log("Page has fully loaded.");
            loadConfigData();
            startDataLoadInterval();
        }

        function startDataLoadInterval() {
            if (intervalId) clearInterval(intervalId);
            intervalId = setInterval(loadConfigData, 5000);
        }

        function showError(msg) {
            const el = document.getElementById('errorBanner');
            el.textContent = msg || '';
            el.style.display = msg ? 'block' : 'none';
            if (msg) setStatus('', '');
        }

        function loadConfigData() {
            showError('');
            fetch('./config')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok ' + response.status + ' ' + response.statusText);
                    }
                    return response.json();
                })
                .then(data => {
                    onConfigDataLoaded(data);
                })
                .catch(error => {
                    console.error("Error loading config data:", error);
                    showError('Failed to load ./config');
                });
        }

        function onConfigDataLoaded(data) {

            if (JSON.stringify(data) !== JSON.stringify(configData)) {
                configData = data.config;
                updatePage();
            }
        }

        function postConfigData() {
            if (!configData) return;
            setStatus('Saving…', '');
            fetch('./setconfig', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(configData)
            }).then(res => {
                if (!res.ok) throw new Error('Failed to save config');
                setStatus('Saved ✓', 'success');
            }).catch(err => {
                console.error('Error saving config:', err);
                setStatus('Save failed', 'error');
            });
        }

        function updatePage() {

            if (!configData) return;
            const deviceIdEl = document.getElementById('deviceId');
            const verboseEl = document.getElementById('verboseLogging');
            const updatedEl = document.getElementById('lastUpdated');
            deviceIdEl.textContent = configData["deviceID"] ?? '';
            verboseEl.textContent = String(!!configData.verboseLogging);
            updatedEl.textContent = new Date().toLocaleString();

            const tbody = document.getElementById('cardsBody');
            tbody.innerHTML = '';

            const cards = Array.isArray(configData.cards) ? configData.cards : [];
            const actions = Array.isArray(configData.avalibleCardActions) ? configData.avalibleCardActions : [];

            if (cards.length > 0) {
                cards.forEach((card, idx) => {
                    const tr = document.createElement('tr');

                    const tdId = document.createElement('td');
                    tdId.className = 'mono';
                    tdId.textContent = card.id ?? '';
                    tr.appendChild(tdId);

                    const tdName = document.createElement('td');
                    const nameInput = document.createElement('input');
                    nameInput.type = 'text';
                    nameInput.value = card.name ?? '';
                    nameInput.addEventListener('change', (e) => {
                        configData.cards[idx].name = e.target.value;
                        postConfigData();
                    });
                    tdName.appendChild(nameInput);
                    tr.appendChild(tdName);

                    const tdEnabled = document.createElement('td');
                    const enabledInput = document.createElement('input');
                    enabledInput.type = 'checkbox';
                    enabledInput.checked = !!card.enabled;
                    enabledInput.addEventListener('change', (e) => {
                        configData.cards[idx].enabled = !!e.target.checked;
                        postConfigData();
                    });
                    tdEnabled.appendChild(enabledInput);
                    tr.appendChild(tdEnabled);

                    const tdActive = document.createElement('td');
                    tdActive.textContent = bool(card.active);
                    tr.appendChild(tdActive);

                    const tdCurrent = document.createElement('td');
                    tdCurrent.textContent = bool(card.current);
                    tr.appendChild(tdCurrent);

                    const tdCommand = document.createElement('td');
                    const commandInput = document.createElement('input');
                    commandInput.type = 'text';
                    commandInput.value = card.command || '';
                    commandInput.addEventListener('change', (e) => {
                        configData.cards[idx].command = e.target.value;
                        postConfigData();
                    });
                    tdCommand.appendChild(commandInput);
                    tr.appendChild(tdCommand);

                    const tdAction = document.createElement('td');
                    const actionSelect = document.createElement('select');
                    const uniqueActions = Array.from(new Set(actions.concat(card.action ? [card.action] : [])));
                    uniqueActions.forEach(act => {
                        const opt = document.createElement('option');
                        opt.value = act;
                        opt.textContent = act;
                        actionSelect.appendChild(opt);
                    });
                    actionSelect.value = card.action || '';
                    actionSelect.addEventListener('change', (e) => {
                        configData.cards[idx].action = e.target.value;
                        postConfigData();
                    });
                    tdAction.appendChild(actionSelect);
                    tr.appendChild(tdAction);

                    const tdActionState = document.createElement('td');
                    tdActionState.textContent = card.actionState || '';
                    tr.appendChild(tdActionState);

                    tbody.appendChild(tr);
                });
            } else {
                const tr = document.createElement('tr');
                tr.innerHTML = `<td colspan="8" class="small">No cards found</td>`;
                tbody.appendChild(tr);
            }

            const actionsUl = document.getElementById('actionsList');
            actionsUl.innerHTML = '';
            (configData.avalibleCardActions || []).forEach(act => {
                const li = document.createElement('li');
                li.textContent = act;
                actionsUl.appendChild(li);
            });
        }

        function bool(val) { return val ? 'Yes' : 'No'; }
        function setStatus(msg, type) {
            const el = document.getElementById('saveStatus');
            if (!el) return;
            el.textContent = msg || '';
            el.className = 'small status ' + (type || '');
            if (msg) {
                el.style.display = 'inline';
                clearTimeout(window._statusTimer);
                window._statusTimer = setTimeout(() => {
                    el.style.display = 'none';
                }, 2000);
            } else {
                el.style.display = 'none';
            }
        }