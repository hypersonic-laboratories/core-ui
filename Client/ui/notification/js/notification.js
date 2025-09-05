const notifications = {};
let notificationZIndex = 1000;

// Icons for different notification types
const icons = {
    success: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>`,
    error: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>`,
    warning: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>`,
    info: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>`
};

// Add a new notification
function addNotification(id, type, title, message, duration) {
    
    // Clone the template
    const template = $('#notification-template').clone();
    template.attr('id', `notification-${id}`);
    template.addClass(`notification-${type}`);
    template.show();
    
    // Set content
    template.find('.notification-icon').html(icons[type] || icons.info);
    template.find('.notification-title').text(title);
    template.find('.notification-message').text(message);
    
    // Add to container
    $('#notification-container').prepend(template);
    
    // Store notification data
    notifications[id] = {
        element: template,
        duration: duration,
        timer: null
    };
    
    // Setup close button
    template.find('.notification-close').on('click', function() {
        removeNotification(id);
    });
    
    // Animate in
    setTimeout(() => {
        template.addClass('show');
    }, 10);
    
    // Start progress animation
    const progressBar = template.find('.notification-progress');
    progressBar.css({
        'animation-duration': `${duration}ms`
    });
    progressBar.addClass('animate');
    
    // Update positions
    updatePositions();
}

// Remove a notification
function removeNotification(id) {
    
    const notification = notifications[id];
    if (!notification) return;
    
    // Clear timer if exists
    if (notification.timer) {
        clearTimeout(notification.timer);
    }
    
    // Animate out
    notification.element.removeClass('show');
    notification.element.addClass('hide');
    
    // Remove after animation
    setTimeout(() => {
        notification.element.remove();
        delete notifications[id];
        updatePositions();
    }, 300);
}

// Update positions of all notifications
function updatePositions() {
    let topOffset = 20;
    const spacing = 10;
    
    $('#notification-container').children('.notification.show').each(function() {
        $(this).css('top', `${topOffset}px`);
        topOffset += $(this).outerHeight() + spacing;
    });
}

// Clear all notifications
function clearAll() {
    
    for (const id in notifications) {
        removeNotification(id);
    }
}

// Initialize
$(document).ready(function() {
});
