// Functions called from Lua to show/hide menus
function showInputMenu(title, placeholder) {
    $('.input-menu .header .title').text(title);
    $('.input-menu input').attr('placeholder', placeholder);
    $('.input-menu input').val(''); // Clear previous value
    $('body').addClass('in-input-menu');
    console.log("Input menu shown with title:", title, "and placeholder:", placeholder);
    // Focus the input with multiple attempts to ensure it works
    const focusInput = () => {
        const input = $('.input-menu input');
        input.focus();
        input.get(0)?.focus(); // Also try native focus
    };

    // Try immediately
    focusInput();

    // Try again after short delays to ensure DOM is ready and visible
    setTimeout(focusInput, 50);
    setTimeout(focusInput, 150);
}

function hideInputMenu() {
    $('.input-menu input').val('');
    $('body').removeClass('in-input-menu');
}

function showConfirmMenu(title, message) {
    $('.confirm-menu .header .title').text(title);
    $('.confirm-menu .message').text(message);
    $('body').addClass('in-confirm-menu');
}

function hideConfirmMenu() {
    $('body').removeClass('in-confirm-menu');
}

function sendInputValue(value) {
    const safeValue = value || "";
    ue.interface.broadcast('OnInputConfirmed', JSON.stringify({ value: safeValue }));
}

function sendInputCancel() {
    ue.interface.broadcast('OnInputCanceled', JSON.stringify({}));
}

function sendConfirmYes() {
    ue.interface.broadcast('OnConfirmYes', JSON.stringify({}));
}

function sendConfirmNo() {
    ue.interface.broadcast('OnConfirmNo', JSON.stringify({}));
}

// Input menu events
// $(document).ready(function() {
// Input menu confirm button
$('.input-menu .confirm').on('click', function () {
    const value = $('.input-menu input').val();
    sendInputValue(value);
});

// Input menu cancel button
$('.input-menu .cancel').on('click', function () {
    sendInputCancel();
});

// Input menu close button (X)
$('.input-menu .close-panel').on('click', function () {
    sendInputCancel();
});

// Confirm menu yes button
$('.confirm-menu .confirm').on('click', function () {
    sendConfirmYes();
});

// Confirm menu no button
$('.confirm-menu .cancel').on('click', function () {
    sendConfirmNo();
});

// Confirm menu close button (X)
$('.confirm-menu .close-panel').on('click', function () {
    sendConfirmNo();
});

// Handle Enter key in input field
$('.input-menu input').on('keypress', function (e) {
    if (e.which === 13) { // Enter key
        const value = $(this).val();
        sendInputValue(value);
    }
});

// Handle Escape key for both menus
$(document).on('keydown', function (e) {
    if (e.which === 27) { // Escape key
        if ($('body').hasClass('in-input-menu')) {
            sendInputCancel();
        } else if ($('body').hasClass('in-confirm-menu')) {
            sendConfirmNo();
        }
    }
});

setTimeout(function() {
    if (typeof ue !== 'undefined' && ue.interface && ue.interface.broadcast) {
        ue.interface.broadcast('Ready', {});
    }
}, 100);