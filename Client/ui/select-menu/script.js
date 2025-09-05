let pendingOptions = [];
let currentOptions = [];
let actualPage = 0;

// DOM References
const $options = {
    header: {
        title: $('.options-selector header h1'),
        playersCount: $('.options-selector header .players-count .value'),
    },
    slider: {
        wrapper: $('.options-selector .slider'),
        options: $('.options-selector .slider .options .scroller'),
        button: $('.options-selector .slider .slide'),
        pages: $('.options-selector .slider .slider-pages'),
    }
};

const $selectedOptionInfo = {
    name: $('.selected-option .option-name'),
    description: $('.selected-option .option-description'),
    infoList: $('.selected-option .info .list'),
};

// Functions called from Lua
function clearOptions() {
    pendingOptions = [];
    currentOptions = [];
    actualPage = 0;
}

function addOption(id, name, image, description) {
    // Find or create option
    let option = pendingOptions.find(opt => opt.id === id);
    if (!option) {
        option = {
            id: id,
            name: name,
            image: image,
            description: description,
            info: []
        };
        pendingOptions.push(option);
    }
}

function addOptionInfo(optionId, infoName, infoValue, infoIcon) {
    let option = pendingOptions.find(opt => opt.id === optionId);
    if (option) {
        option.info.push({
            name: infoName,
            value: infoValue,
            icon: infoIcon
        });
    }
}

function buildMenu() {
    currentOptions = pendingOptions;
    renderOptions();
    
    // Select first option by default
    if (currentOptions.length > 0) {
        setSelectedOptionInfo(currentOptions[0]);
    }
}

function setMenuTitle(title) {
    $options.header.title.text(title);
}

function setPlayersCount(count) {
    $options.header.playersCount.text(count);
}

function showMenu() {
    $('body').removeClass('hidden');
}

function hideMenu() {
    $('body').addClass('hidden');
}

// Internal functions
function renderOptions() {
    $options.slider.options.find('.option').remove();
    
    currentOptions.forEach((option, index) => {
        $options.slider.options.append(`<div class="option ${index == 0 ? "selected" : ""}" data-id="${option.id}">
            <img src="${option.image}" alt="${option.name}" class="bg">
            <p class="name">${option.name}</p>
            <p class="votes">0</p>
        </div>`);
    });

    // Setup pagination if needed
    if (currentOptions.length > 6) {
        $options.slider.wrapper.removeClass('disabled');
        $options.slider.wrapper.find('.button.right').removeClass('disabled');

        let pages = Math.ceil((currentOptions.length - 6) / 2);

        $options.slider.pages.empty();
        for (let i = 0; i < pages + 1; i++) {
            $options.slider.pages.append(`<div class="page ${i == 0 ? "selected" : ""}"></div>`);
        }
    } else {
        $options.slider.wrapper.addClass('disabled');
        $options.slider.pages.empty();
    }
}

function setSelectedOptionInfo(option) {
    $selectedOptionInfo.name.text(option.name);
    $selectedOptionInfo.description.text(option.description);

    $selectedOptionInfo.infoList.empty();
    if (option.info) {
        option.info.forEach(info => {
            $selectedOptionInfo.infoList.append(`<div>
                <img src="${info.icon}" alt="${info.name}" class="icon">
                <p class="name">${info.name}</p>
                <p class="value">${info.value}</p>
            </div>`);
        });
    }
}

function sendOptionSelected(optionId) {
    ue.interface.broadcast('OnOptionSelected', JSON.stringify({ optionId: optionId }));
}

// Event handlers
$(document).ready(function() {
    // Option click handler (delegated for dynamic content)
    $(document).on('click', '.options .option', function() {
        $('.options .option').removeClass('selected');
        $(this).addClass('selected');

        let optionId = $(this).data('id');
        let option = currentOptions.find(opt => opt.id === optionId);
        if (option) {
            setSelectedOptionInfo(option);
            sendOptionSelected(optionId);
        }
    });

    // Page navigation click handler
    $(document).on('click', '.slider .slider-pages .page', function() {
        let index = $(this).index();
        actualPage = index;
        let optionWidth = $options.slider.options.find('.option').outerWidth(true) + 20;
        $options.slider.options.css('transform', `translateX(${-index * optionWidth * 2}px)`);

        $options.slider.pages.find('.page').removeClass('selected');
        $(this).addClass('selected');

        $options.slider.button.removeClass('unable');
        if (index == 0) {
            $('.slider button.slide[data-side="left"]').addClass('unable');
        } else if (index == $options.slider.pages.find('.page').length - 1) {
            $('.slider button.slide[data-side="right"]').addClass('unable');
        }
    });

    // Slider button handlers
    $('.slider button.slide').click(function(e) {
        if ($(this).hasClass('unable')) return;
        
        let optionWidth = $options.slider.options.find('.option').outerWidth(true) + 20;
        let transform = $options.slider.options.css('transform');
        let actualTranslate = transform === 'none' ? 0 : parseInt(transform.split(',')[4]);
        let dataSide = $(this).attr('data-side');

        if (dataSide == "left") {
            actualPage--;
            $options.slider.options.css('transform', `translateX(${actualTranslate + optionWidth * 2}px)`);
        } else {
            actualPage++;
            $options.slider.options.css('transform', `translateX(${actualTranslate - optionWidth * 2}px)`);
        }

        $options.slider.pages.find('.page').removeClass('selected');
        $options.slider.pages.find(`.page:nth-child(${actualPage + 1})`).addClass('selected');

        $options.slider.button.removeClass('unable');
        if (actualPage == 0) {
            $('.slider button.slide[data-side="left"]').addClass('unable');
        } else if (actualPage == $options.slider.pages.find('.page').length - 1) {
            $('.slider button.slide[data-side="right"]').addClass('unable');
        }
    });

    // Backspace key handler
    $(document).on('keydown', function(e) {
        if (e.which === 8) { // Backspace
            e.preventDefault();
            if (!$('body').hasClass('hidden')) {
                ue.interface.broadcast('OnBackspace', JSON.stringify({}));
            }
        }
    });
});