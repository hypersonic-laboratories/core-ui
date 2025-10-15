const interactions = {};
let containerVisible = false;

function ShowContainer() {
    if (containerVisible) return;
    $('#interactions-container').removeClass('hidden');
    containerVisible = true;
}

function HideContainer() {
    if (!containerVisible) return;
    $('#interactions-container').addClass('hidden');
    containerVisible = false;
}

function addInteraction(id, text, key, duration) {
    const template = $('#interaction-template').clone();
    template.attr('id', `interaction-${id}`);
    template.addClass('visible');
    template.show();

    template.find('.interaction-text').text(text.toUpperCase());
    template.find('.key-text').text(key.toUpperCase());

    $('#interactions-container').append(template);

    interactions[id] = {
        element: template,
        duration: duration
    };

    ShowContainer();

    setTimeout(() => {
        template.addClass('show');
    }, 50);
}

function removeInteraction(id) {
    const interaction = interactions[id];
    if (!interaction) return;

    interaction.element.removeClass('show');

    setTimeout(() => {
        interaction.element.remove();
        delete interactions[id];
        checkVisibility();
    }, 300);
}

function checkVisibility() {
    const visibleInteractions = $('#interactions-container').children('.interaction-item.show');

    if (visibleInteractions.length === 0) {
        HideContainer();
        hEvent('AllInteractionsClosed');
    }
}

function startProgress(id) {
    const interaction = interactions[id];
    if (!interaction) return;

    interaction.element.addClass('pressing');
}

function updateProgressFromLua(id, progress) {
    const interaction = interactions[id];
    if (!interaction) return;

    const circle = interaction.element.find('.progress-circle');
    circle.css({
        'stroke': '#00FBDD',
        'stroke-dasharray': `${progress}, 100`
    });
}

function resetProgress(id) {
    const interaction = interactions[id];
    if (!interaction) return;

    interaction.element.removeClass('pressing');

    const circle = interaction.element.find('.progress-circle');
    circle.css({
        'stroke': 'transparent',
        'stroke-dasharray': '0, 100',
        'transition': 'stroke-dasharray 0.3s ease-out'
    });
}


function clearAll() {
    for (const id in interactions) {
        removeInteraction(id);
    }
    HideContainer();
}

ue.interface.broadcast('Ready', {});
