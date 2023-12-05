function addMenuOption(id, text, backgroundImage, description) {
  const container = document.getElementById('menu-container');


  const optionContainer = document.createElement('div');
  optionContainer.className = 'menu-option-container';


  const option = document.createElement('div');
  option.className = 'menu-option';
  option.id = id;
  option.style.backgroundImage = `url(${backgroundImage})`;


  const textElement = document.createElement('div');
  textElement.className = 'menu-option-text';
  textElement.textContent = text;
  option.appendChild(textElement); 


  const descriptionElement = document.createElement('div');
  descriptionElement.className = 'menu-option-description';
  descriptionElement.textContent = description;


  optionContainer.addEventListener('click', function () {
    showNotification('Selected option: ' + text);
    Events.Call("ExecuteOptionCallback", id)

  });

  optionContainer.appendChild(option);
  optionContainer.appendChild(descriptionElement);

 
  container.appendChild(optionContainer);
}

function showNotification(message) {
  let notification = document.querySelector('.notification');
  if (!notification) {
    notification = document.createElement('div');
    notification.className = 'notification';
    document.body.appendChild(notification);
  }


  notification.textContent = message;
  notification.style.display = 'block';


  setTimeout(function () {
    notification.style.display = 'none';
  }, 3000);
}

function openMenuWithOptions(options) {
  const menuContainer = document.getElementById('menu-container');
  menuContainer.innerHTML = '';
  menuContainer.style.display = 'grid'; 

 
  options.forEach(function(option) {
    addMenuOption(option.id, option.text, option.image, option.description);
  });
}

function closeMenu() {
  const menuContainer = document.getElementById('menu-container');
  menuContainer.style.display = 'none';
}

Events.Subscribe("OpenOptionsMenu", function(options) {
  openMenuWithOptions(options);
});

Events.Subscribe("closeSelectMenu", function() {
  closeMenu();
});
