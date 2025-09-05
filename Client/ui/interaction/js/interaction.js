const interactions = {};

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
        duration: duration,
        progress: 0,
        animating: false
    };
    
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
    }, 300);
}

function startProgress(id) {
    const interaction = interactions[id];
    if (!interaction) return;
    
    interaction.animating = true;
    interaction.startTime = Date.now();
    
    interaction.element.addClass('pressing');
    
    animateProgress(id);
}

function updateProgress(id, progress) {
    const interaction = interactions[id];
    if (!interaction) return;
    
    interaction.progress = progress;
    
    const circle = interaction.element.find('.progress-circle');
    circle.css({
        'stroke': '#00FBDD',
        'stroke-dasharray': `${progress}, 100`,
        'transition': 'stroke-dasharray 0.1s linear'
    });
}

function resetProgress(id) {
    const interaction = interactions[id];
    if (!interaction) return;
    
    interaction.animating = false;
    interaction.progress = 0;
    
    interaction.element.removeClass('pressing');
    
    const circle = interaction.element.find('.progress-circle');
    circle.css({
        'stroke': 'transparent',
        'stroke-dasharray': '0, 100',
        'transition': 'stroke-dasharray 0.3s ease-out'
    });
}

function animateProgress(id) {
    const interaction = interactions[id];
    if (!interaction || !interaction.animating) return;
    
    const elapsed = Date.now() - interaction.startTime;
    const progress = Math.min((elapsed / interaction.duration) * 100, 100);
    
    updateProgress(id, progress);
    
    if (progress < 100 && interaction.animating) {
        requestAnimationFrame(() => animateProgress(id));
    }
}

function clearAll() {
    for (const id in interactions) {
        removeInteraction(id);
    }
}

$(document).ready(function() {
    const keysPressed = {};
    
    $(document).on('keydown', function(e) {
        const key = e.key.toUpperCase();
        
        for (const id in interactions) {
            const interaction = interactions[id];
            if (interaction.element.find('.key-text').text() === key) {
                e.preventDefault();
                
                if (!keysPressed[key]) {
                    keysPressed[key] = true;
                    startProgress(id);
                }
                break;
            }
        }
    });
    
    $(document).on('keyup', function(e) {
        const key = e.key.toUpperCase();
        
        if (keysPressed[key]) {
            keysPressed[key] = false;
            
            for (const id in interactions) {
                const interaction = interactions[id];
                if (interaction.element.find('.key-text').text() === key) {
                    if (interaction.progress >= 100) {
                        ue.interface.broadcast('InteractionComplete', JSON.stringify({ id: id }));
                        removeInteraction(id);
                    } else {
                        resetProgress(id);
                        if (interaction.progress > 10) {
                            ue.interface.broadcast('InteractionCancelled', JSON.stringify({ id: id }));
                        }
                    }
                    break;
                }
            }
        }
    });
});