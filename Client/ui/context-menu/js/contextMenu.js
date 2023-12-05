function buildContextMenu(items) {
    const menu = document.getElementById('contextMenu');
    menu.innerHTML = '';

    items.forEach(item => {
        let container = document.createElement('div');
        container.classList.add('menu-item');
        let element;

        switch (item.type) {
            case 'checkbox':
                element = document.createElement('input');
                element.type = 'checkbox';
                element.checked = item.checked;
                element.id = item.id;

                element.addEventListener('change', () => {
                    console.log('Checkbox ID:', item.id, 'Status:', element.checked);
                    Events.Call("ExecuteCallback", item.id);
                });

                if (item.label) {
                    let label = document.createElement('label');
                    label.textContent = item.label + ' ';
                    container.appendChild(label);
                }
                container.appendChild(element);
                break;
            case 'dropdown':
                element = document.createElement('select');
                element.id = item.id;

                item.options.forEach(opt => {
                    const option = document.createElement('option');
                    option.value = opt.value;
                    option.text = opt.text;
                    element.appendChild(option);
                });

                element.addEventListener('change', () => {
                    console.log('Dropdown ID:', item.id, 'Selected Value:', element.value);
                    Events.Call("ExecuteCallback", item.id, element.value);
                });

                container.appendChild(element);
                break;
            case 'button':
                element = document.createElement('button');
                element.textContent = item.text;
                element.id = item.id;

                element.addEventListener('click', () => {

                    console.log('Button ID:', item.id);
                    Events.Call("ExecuteCallback", item.id);
                });

                container.appendChild(element);
                break;
            case 'text-input':
                element = document.createElement('button');
                element.textContent = item.text;
                element.id = item.id;

                element.addEventListener('click', () => {
                    openTextInputModal(item.id);
                });

                container.appendChild(element);
                break;
            case 'range':
                element = document.createElement('input');
                element.type = 'range';
                element.id = item.id;
                element.min = item.min || 0;
                element.max = item.max || 100;
                element.value = item.value || 0;


                element.addEventListener('input', () => {
                    console.log('Range ID:', item.id, 'Value:', element.value);
                    Events.Call("ExecuteCallback", item.id, element.value);
                });

                if (item.label) {
                    let label = document.createElement('label');
                    label.textContent = item.label + ' ';
                    container.appendChild(label);
                }
                container.appendChild(element);
                break;

        }

        container.style.width = '100%';
        menu.appendChild(container);
    });

    menu.style.display = 'block';
}

function openTextInputModal(id) {
    const modalContainer = document.createElement('div');
    modalContainer.id = 'text-input-modal-container';
    modalContainer.classList.add('modal-container');
    modalContainer.style.display = 'block';
    const title = document.createElement('h3');
    title.textContent = 'Focking title';
    title.classList.add('modal-title');


    const closeButton = document.createElement('span');
    closeButton.textContent = 'X';
    closeButton.classList.add('modal-close-button');
    closeButton.addEventListener('click', () => {
        modalContainer.style.display = 'none';
        Events.Call("CloseMenu")
    });

    const textInput = document.createElement('input');
    textInput.type = 'text';
    textInput.id = 'text-input-modal';

    const submitButton = document.createElement('button');
    submitButton.textContent = 'Submit';
    submitButton.addEventListener('click', () => {
        const value = textInput.value;
        console.log('Text Input ID:', id, 'Value:', value);
        modalContainer.style.display = 'none';
        Events.Call("ExecuteCallback", id, value);
    });

    modalContainer.appendChild(title);
    modalContainer.appendChild(closeButton);
    modalContainer.appendChild(textInput);
    modalContainer.appendChild(submitButton);

    document.body.appendChild(modalContainer);
}

function ShowNotification(title, message, duration, position, color) {
    var notification = document.createElement("div");
    notification.className = 'notification ' + position;
    notification.style.borderColor = color;


    var notificationTitle = document.createElement("div");
    notificationTitle.innerText = title;
    notificationTitle.className = 'notification-title';
    notification.appendChild(notificationTitle);


    var separator = document.createElement("hr");
    notification.appendChild(separator);


    var notificationMessage = document.createElement("div");
    notificationMessage.innerText = message;
    notificationMessage.className = 'notification-message';
    notification.appendChild(notificationMessage);

    document.body.appendChild(notification);


    setTimeout(function () {
        notification.remove();
    }, duration * 1000);
}

Events.Subscribe("buildContextMenu", function (items) {
    buildContextMenu(items);
})

Events.Subscribe("ShowNotification", function (data) {
    ShowNotification(data.title, data.message, data.duration, data.pos, data.color);
})


Events.Subscribe("closeContextMenu", function () {
    console.log("Cerrando menu")
    const menu = document.getElementById('contextMenu');
    menu.style.display = 'none';
});