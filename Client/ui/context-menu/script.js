// General
let isInDropdown = false;
let scrollDelay = false;
let persistentOptions = null;
$(document).on('keydown', function (e) {

    if (e.keyCode == 13) {
        let $selected = $('.option.selected') || $('.dropdown.selected');

        if ($selected.hasClass('checkbox') || $selected.hasClass('action') || $selected.hasClass('text-input')) {
            let id = $selected.data('id');
            let option = findOptionById(persistentOptions, id);
            if (option) {
                if ($selected.hasClass('checkbox')) {
                    option.checked = !option.checked;
                    $selected.toggleClass('active');
                } else if ($selected.hasClass('action')) {
                    Events.Call("ExecuteCallback", id, option);
                } else if ($selected.hasClass('text-input')) {
                    let value = $selected.find('.input input').val();
                    $selected.find('input').focus()
                    Events.Call("ExecuteCallback", id, value);
                }
            }
        } else if ($selected.parent().hasClass('dropdown')) {
            $selected.find('svg').click();
            $('.option').removeClass('selected')
            if ($selected.parent().hasClass('active')) {

            }
            $selected.parent().addClass('active')
            $selected.parent().find('.sub-list .option').eq(0).addClass('selected')
            isInDropdown = true;
        }
    }

    let $selected = $('.option.selected');

    if (e.keyCode == 38 || e.keyCode == 40) {

        if (scrollDelay) return;
        scrollDelay = true;

        $('input').blur();

        let $allOptions = $('.option, .dropdown .option').not('.sub-list .option'); 
        let index = $allOptions.index($selected);

        if (isInDropdown) {
            $allOptions = $('.option.selected').parent().find('.option');
            index = $allOptions.index($selected);
        }

        if (e.keyCode == 38) { 
            if (index > 0) {
                $selected.removeClass('selected');
                $allOptions.eq(index - 1).addClass('selected');
            }
        }

        if (e.keyCode == 40) { 
            if (index < $allOptions.length - 1) {
                $selected.removeClass('selected');
                $allOptions.eq(index + 1).addClass('selected');
            }
        }

        $('.option.selected').get(0).scrollIntoView({ behavior: 'smooth', block: 'nearest' });

        setTimeout(() => {
            scrollDelay = false;
        }, 50);
    }

    if (e.keyCode == 37 || e.keyCode == 39) {
        if ($selected.hasClass('quantity')) {
            let id = $selected.data('id');
            let option = findOptionById(hardcodedItems, id);
            let $value = $selected.find('.value');
            let value = parseInt($value.val());
            let min = option.min;
            let max = option.max;

            if (e.keyCode == 37) {
                if (value > min) {
                    value--;
                    $value.val(value);
                    option.value = value;
                }
            }

            if (e.keyCode == 39) { 
                if (value < max) {
                    value++;
                    $value.val(value);
                    option.value = value;
                }
            }

            $selected.find('.less').toggleClass('unable', value == min);
            $selected.find('.more').toggleClass('unable', value == max);

            $value.css('width', ($value.val().length * 8) + 'px');
        } else if ($selected.hasClass('list')) {
            let id = $selected.data('id');
            let option = findOptionById(hardcodedItems, id);
            let $value = $selected.find('.value');
            let value = $value.text();
            let list = option.list;
            let index = list.findIndex(item => item.label === value);

            if (e.keyCode == 37) {
                if (index > 0) {
                    index--;
                    $value.text(list[index].label);
                }
            }

            if (e.keyCode == 39) {
                if (index < list.length - 1) {
                    index++;
                    $value.text(list[index].label);
                }
            }

            $selected.find('.left').toggleClass('unable', index == 0);
            $selected.find('.right').toggleClass('unable', index == list.length - 1);
        }
    }


    if (e.keyCode == 8 && isInDropdown) {
        $('.option').removeClass('selected')
        $selected.parent().parent().find('.option').not('.sub-list .option').removeClass('active')
        $selected.parent().parent().find('.option').not('.sub-list .option').addClass('selected')
        $selected.parent().css('height', '0px')
        isInDropdown = false;
    }
});

// Notification
const showNotification = (type, title, description) => {
    let element = `<div class="notification entering ${type}" ${description ? "" : "style='align-items: center !important;'"}>
        <div class="icon">
            <img src="./media/icons/notif_${type}.svg" alt="">
        </div>
        <div class="content">
            <h1 class="title">${title}</h1>
            ${description ? `<p class="description">${description}</p>` : ""}
        </div>
        <svg class="close" width="20" height="20" viewBox="0 0 20 20" fill="none"
            xmlns="http://www.w3.org/2000/svg">
            <path d="M15 5L5 15M5 5L15 15" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
    </div>`

    let $element = $(element)
    $('.notifications').append($element);

    setTimeout(() => {
        $element.removeClass('entering').addClass('entered');
    }, 100);

    setTimeout(() => {
        $element.removeClass('entered').addClass('leaving');
    }, 5000);

    setTimeout(() => {
        $element.remove();
    }, 5500);

    $element.find('.close').on('click', function () {
        $element.removeClass('entered').addClass('leaving');
        setTimeout(() => {
            $element.remove();
        }, 500);
    });

}


const showUi = () => {
    $('.screen').removeClass('hidden');
}

const hideUi = () => {
    $('.screen').addClass('hidden');
}


{/* <div class="options">
<div class="option checkbox">
    <p class="name">spawn random vehicle</p>
    <div class="check">
        <svg width="16" height="12" viewBox="0 0 16 12" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
                d="M5.90784 8.62145L2.66811 5.38172C2.47662 5.19022 2.2169 5.08265 1.94609 5.08265C1.67528 5.08265 1.41556 5.19022 1.22407 5.38172C1.03258 5.57321 0.924999 5.83292 0.924999 6.10373C0.924999 6.23783 0.95141 6.3706 1.00272 6.49449C1.05404 6.61837 1.12925 6.73094 1.22407 6.82575L5.19053 10.7922C5.5899 11.1916 6.2352 11.1916 6.63457 10.7922L14.7763 2.65053C14.9677 2.45904 15.0753 2.19932 15.0753 1.92851C15.0753 1.6577 14.9677 1.39798 14.7763 1.20649C14.5848 1.015 14.325 0.907421 14.0542 0.907421C13.7834 0.907421 13.5237 1.01499 13.3323 1.20646C13.3322 1.20647 13.3322 1.20648 13.3322 1.20649M5.90784 8.62145L13.3322 1.20649M5.90784 8.62145L13.3322 1.20649M5.90784 8.62145L13.3322 1.20649"
                stroke-width="0.150002" />
        </svg>
    </div>
</div>
<div class="option server">
    <p class="name">parallel city online</p>
    <p class="counter">32/64</p>
</div>
<div class="option dropdown active">
    <p class="name">dropdown/dropdown</p>
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M4.58398 7.29199L10.0007 12.7087L15.4173 7.29199" stroke-width="2"
            stroke-linecap="round" stroke-linejoin="round" />
    </svg>
</div>
<div class="option quantity active">
    <p class="name">Quantity</p>
    <div class="controls">
        <button class="less">
            <svg width="12" height="2" viewBox="0 0 12 2" fill="none"
                xmlns="http://www.w3.org/2000/svg">
                <rect x="0.25" y="0.115234" width="11.5" height="1.76923" rx="0.884615" />
            </svg>
        </button>
        <p class="value">1</p>
        <button class="more">
            <svg width="12" height="12" viewBox="0 0 12 12" fill="none"
                xmlns="http://www.w3.org/2000/svg">
                <path
                    d="M6 11.75C5.76726 11.75 5.57204 11.6711 5.41432 11.5134C5.25661 11.3557 5.17802 11.1608 5.17857 10.9286V6.82143H1.07143C0.838693 6.82143 0.643467 6.74257 0.485753 6.58486C0.328039 6.42714 0.249455 6.23219 0.250003 6C0.250003 5.76726 0.32886 5.57204 0.486574 5.41432C0.644288 5.25661 0.839241 5.17802 1.07143 5.17857H5.17857V1.07143C5.17857 0.838693 5.25743 0.643467 5.41514 0.485753C5.57286 0.328039 5.76781 0.249455 6 0.250003C6.23274 0.250003 6.42796 0.32886 6.58568 0.486574C6.74339 0.644288 6.82198 0.839241 6.82143 1.07143V5.17857H10.9286C11.1613 5.17857 11.3565 5.25743 11.5142 5.41514C11.672 5.57286 11.7505 5.76781 11.75 6C11.75 6.23274 11.6711 6.42796 11.5134 6.58568C11.3557 6.74339 11.1608 6.82198 10.9286 6.82143H6.82143V10.9286C6.82143 11.1613 6.74257 11.3565 6.58486 11.5142C6.42714 11.672 6.23219 11.7505 6 11.75Z" />
            </svg>
        </button>
    </div>
</div>
<div class="option navigate">
    <p class="name">Navigate</p>
    <svg width="15" height="12" viewBox="0 0 15 12" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path
            d="M8.95665 11.1511C8.76404 10.9585 8.67158 10.7257 8.67929 10.4529C8.68699 10.18 8.78747 9.94723 8.98073 9.75462L11.7014 7.03392H0.963084C0.690211 7.03392 0.461319 6.94146 0.276408 6.75655C0.0914962 6.57164 -0.000638721 6.34307 3.33245e-06 6.07083C3.33245e-06 5.79796 0.0924592 5.56907 0.277371 5.38416C0.462282 5.19925 0.690853 5.10711 0.963084 5.10775H11.7014L8.95665 2.36297C8.76404 2.17036 8.66773 1.94147 8.66773 1.6763C8.66773 1.41113 8.76404 1.18256 8.95665 0.990584C9.14927 0.797968 9.37816 0.70166 9.64333 0.70166C9.9085 0.70166 10.1371 0.797968 10.329 0.990584L14.7351 5.39668C14.8314 5.49299 14.8998 5.59732 14.9403 5.70968C14.9807 5.82204 15.0006 5.94242 15 6.07083C15 6.19925 14.9798 6.31963 14.9393 6.43199C14.8989 6.54435 14.8308 6.64868 14.7351 6.74499L10.305 11.1752C10.1284 11.3517 9.90786 11.44 9.64333 11.44C9.3788 11.44 9.14991 11.3437 8.95665 11.1511Z" />
    </svg>
</div>
<div class="option action">
    <p class="name">Action</p>
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path
            d="M7.90784 12.6219L4.66811 9.3822C4.47662 9.19071 4.2169 9.08313 3.94609 9.08313C3.67528 9.08313 3.41556 9.19071 3.22407 9.3822C3.03258 9.5737 2.925 9.83341 2.925 10.1042C2.925 10.2383 2.95141 10.3711 3.00272 10.495C3.05404 10.6189 3.12925 10.7314 3.22407 10.8262L7.19053 14.7927C7.5899 15.1921 8.2352 15.1921 8.63457 14.7927L16.7763 6.65102C16.9677 6.45952 17.0753 6.19981 17.0753 5.929C17.0753 5.65819 16.9677 5.39847 16.7763 5.20698C16.5848 5.01549 16.325 4.90791 16.0542 4.90791C15.7834 4.90791 15.5237 5.01548 15.3323 5.20695C15.3322 5.20696 15.3322 5.20697 15.3322 5.20698M7.90784 12.6219L15.3322 5.20698M7.90784 12.6219L15.3322 5.20698M7.90784 12.6219L15.3322 5.20698"
            stroke-width="0.150002" />
    </svg>
</div>
<div class="option text-input">
    <p class="name">Input text</p>
    <div class="input">
        <input type="text" placeholder="Enter text">
    </div>
</div>
<div class="option list active">
    <p class="name">Quantity</p>
    <div class="controls">
        <button class="left">
            <svg width="6" height="10" viewBox="0 0 6 10" fill="none"
                xmlns="http://www.w3.org/2000/svg">
                <path
                    d="M5.1333 9.0291C5.1333 9.19293 5.07869 9.32472 4.96947 9.42447C4.86025 9.52423 4.73283 9.57447 4.5872 9.5752C4.5508 9.5752 4.42338 9.52059 4.20494 9.41137L0.245742 5.45217C0.154727 5.36116 0.0910162 5.27014 0.0546098 5.17912C0.0182034 5.08811 0 4.98799 0 4.87877C0 4.76955 0.0182034 4.66943 0.0546098 4.57842C0.0910162 4.4874 0.154727 4.39639 0.245742 4.30537L4.20494 0.346176C4.25955 0.291566 4.31889 0.250426 4.38296 0.222757C4.44704 0.195088 4.51512 0.18162 4.5872 0.182347C4.73283 0.182347 4.86025 0.232224 4.96947 0.331977C5.07869 0.43173 5.1333 0.563886 5.1333 0.728442L5.1333 9.0291Z" />
            </svg>
        </button>
        <p class="value">Sniper rifle</p>
        <button class="right">
            <svg width="6" height="10" viewBox="0 0 6 10" fill="none"
                xmlns="http://www.w3.org/2000/svg">
                <path
                    d="M0.866699 0.850783C0.866699 0.686955 0.921309 0.555163 1.03053 0.45541C1.13975 0.355656 1.26717 0.305416 1.4128 0.304688C1.4492 0.304688 1.57662 0.359297 1.79506 0.468516L5.75426 4.42771C5.84527 4.51873 5.90898 4.60974 5.94539 4.70076C5.9818 4.79178 6 4.89189 6 5.00111C6 5.11033 5.9818 5.21045 5.94539 5.30146C5.90898 5.39248 5.84527 5.4835 5.75426 5.57451L1.79506 9.53371C1.74045 9.58832 1.68111 9.62946 1.61704 9.65713C1.55296 9.68479 1.48488 9.69826 1.4128 9.69754C1.26717 9.69754 1.13975 9.64766 1.03053 9.54791C0.921309 9.44815 0.866699 9.316 0.866699 9.15144L0.866699 0.850783Z" />
            </svg>
        </button>
    </div>
</div>
</div> */}

const $options = $('.content .options');

const setOptions = (options) => {
    $options.empty();
    persistentOptions = options;
    options.forEach(option => {
        let type = option.type;

        switch (type) {
            case 'checkbox':
                $options.append(getCheckbox(option));
                break;
            case 'dropdown':
                $options.append(getDropdown(option));
                break;
            case 'button':
                $options.append(getButton(option));
                break;
            case 'text-input':
                $options.append(getTextInput(option));
                break;
            case 'range':
                $options.append(getRange(option));
                break;
            case 'list':
                $options.append(getList(option));
                break;
            default:
                break;
        }
    });

    $('.option.checkbox').on('click', function (e) {
        let id = $(this).data('id');
        let option = findOptionById(options, id);
        $('.option').removeClass('selected')
        $(this).addClass('selected')
        Events.Call("ExecuteCallback", id, option);
    });

    $('.option.checkbox .check').on('click', function (e) {
        let id = $(this).parent().data('id');
        let option = findOptionById(options, id);
        $('.option').removeClass('selected')

        $(this).parent().addClass('selected')
        if ($(this).hasClass('check')) {
            $(this).parent().toggleClass('active')
        }
    });

    $('.dropdown > .option svg').on('click', function () {
        let id = $(this).parent().parent().data('id');
        let option = findOptionById(options, id);
        $('.option').removeClass('selected')
        $(this).parent().toggleClass('active').addClass('selected')

        if ($(this).parent().hasClass('active')) {
            $(this).parent().parent().find('.sub-list').css('height', ((52 * option.options.length - 8)) + 'px')
            isInDropdown = true;
        } else {
            $(this).parent().parent().find('.sub-list').removeClass('.hidden')
            $(this).parent().parent().find('.sub-list').css('height', '0px')
            isInDropdown = false;
        }

        $('.options-qty .qty').text((parseInt($('.option.selected').parent().index()) + 1) + "/" + options.length);
    });

    $('.option.action').on('click', function () {
        let id = $(this).data('id');
        let option = findOptionById(options, id);
        Events.Call("ExecuteCallback", id, option);

    });

    $('.option.text-input').on('click', function () {
        let id = $(this).data('id');
        let option = findOptionById(options, id);
        $('.option').removeClass('selected')
        $(this).toggleClass('active').addClass('selected')
    });

    $('.option.quantity .controls button').on('click', function () {
        let id = $(this).parent().parent().data('id');
        let option = findOptionById(options, id);
        let $value = $(this).parent().find('.value');
        let value = parseInt($value.val());
        let min = option.min;
        let max = option.max;

        if ($(this).hasClass('less')) {
            if (value > min) {
                value--;
                $value.val(value);
                option.value = value;
            }
        } else {
            if (value < max) {
                value++;
                $value.val(value);
                option.value = value;
            }
        }
        Events.Call("ExecuteCallback", id, value);

        $(this).parent().find('.less').toggleClass('unable', value == min);
        $(this).parent().find('.more').toggleClass('unable', value == max);

        $value.css('width', ($value.val().length * 8) + 'px');
    });

    $('.option.list .controls button').on('click', function () {
        let id = $(this).parent().parent().data('id');
        let option = findOptionById(options, id);
        let $value = $(this).parent().find('.value');
        let value = $value.text();
        let list = option.list;
        let index = list.findIndex(item => item.label === value);

        if ($(this).hasClass('left')) {
            if (index > 0) {
                index--;
                $value.text(list[index].label);
            }
        } else {
            if (index < list.length - 1) {
                index++;
                $value.text(list[index].label);
            }
        }

        $(this).parent().find('.left').toggleClass('unable', index == 0);
        $(this).parent().find('.right').toggleClass('unable', index == list.length - 1);
    });

    $('.option.list, .option.quantity').on('click', function (e) {
        // prevent of click a child, and select the option
        e.stopPropagation();
        $('.option').removeClass('selected')
        $(this).addClass('selected')
    });


    $('.option.quantity input.value').on('input', function () {
        // $(this).css('width', ($(this).val().length * 8) + 'px');

        let id = $(this).parent().parent().data('id');
        let option = findOptionById(options, id);
        let value = parseInt($(this).val());

        if (value == "" || isNaN(value)) {
            value = 1;
        } else if (value > option.max) {
            value = option.max;
        } else if (value < option.min) {
            value = option.min;
        }

        $(this).val(value);
        Events.Call("ExecuteCallback", id, value);

        $(this).parent().find('.less').toggleClass('unable', value == option.min);
        $(this).parent().find('.more').toggleClass('unable', value == option.max);

        $(this).css('width', ($(this).val().length * 8) + 'px');
    });
}

const getCheckbox = (option) => {
    return `<div class="option checkbox ${option.active ? "active" : ""}" data-id="${option.id}">
        <p class="name">${option.label}</p>
        <div class="check">
            <svg width="16" height="12" viewBox="0 0 16 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path
                    d="M5.90784 8.62145L2.66811 5.38172C2.47662 5.19022 2.2169 5.08265 1.94609 5.08265C1.67528 5.08265 1.41556 5.19022 1.22407 5.38172C1.03258 5.57321 0.924999 5.83292 0.924999 6.10373C0.924999 6.23783 0.95141 6.3706 1.00272 6.49449C1.05404 6.61837 1.12925 6.73094 1.22407 6.82575L5.19053 10.7922C5.5899 11.1916 6.2352 11.1916 6.63457 10.7922L14.7763 2.65053C14.9677 2.45904 15.0753 2.19932 15.0753 1.92851C15.0753 1.6577 14.9677 1.39798 14.7763 1.20649C14.5848 1.015 14.325 0.907421 14.0542 0.907421C13.7834 0.907421 13.5237 1.01499 13.3323 1.20646C13.3322 1.20647 13.3322 1.20648 13.3322 1.20649M5.90784 8.62145L13.3322 1.20649M5.90784 8.62145L13.3322 1.20649M5.90784 8.62145L13.3322 1.20649"
                    stroke-width="0.150002" />
            </svg>
        </div>
    </div>`
}

const getDropdown = (option) => {
    let subOptions = '';

    option.options.forEach(option => {
        let type = option.type;

        switch (type) {
            case 'checkbox':
                subOptions += getCheckbox(option);
                break;
            case 'dropdown':
                subOptions += getDropdown(option);
                break;
            case 'text-input':
                subOptions += getTextInput(option);
                break;
            case 'range':
                subOptions += getRange(option);
                break;
            default:
                break;
        }
    });

    return `<div class="dropdown" data-id="${option.id}">
        <div class="option">
            <p class="name">${option.label}</p>
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M4.58398 7.29199L10.0007 12.7087L15.4173 7.29199" stroke-width="2"
                    stroke-linecap="round" stroke-linejoin="round" />
            </svg>
        </div>
        <div class="sub-list">
            ${subOptions}
        </div>
    </div>`
}

const getButton = (option) => {
    return `<div class="option action ${option.active ? "active" : ""}" data-id="${option.id}">
        <p class="name">${option.label || option.text}</p>
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
                d="M7.90784 12.6219L4.66811 9.3822C4.47662 9.19071 4.2169 9.08313 3.94609 9.08313C3.67528 9.08313 3.41556 9.19071 3.22407 9.3822C3.03258 9.5737 2.925 9.83341 2.925 10.1042C2.925 10.2383 2.95141 10.3711 3.00272 10.495C3.05404 10.6189 3.12925 10.7314 3.22407 10.8262L7.19053 14.7927C7.5899 15.1921 8.2352 15.1921 8.63457 14.7927L16.7763 6.65102C16.9677 6.45952 17.0753 6.19981 17.0753 5.929C17.0753 5.65819 16.9677 5.39847 16.7763 5.20698C16.5848 5.01549 16.325 4.90791 16.0542 4.90791C15.7834 4.90791 15.5237 5.01548 15.3323 5.20695C15.3322 5.20696 15.3322 5.20697 15.3322 5.20698M7.90784 12.6219L15.3322 5.20698M7.90784 12.6219L15.3322 5.20698M7.90784 12.6219L15.3322 5.20698"
                stroke-width="0.150002" />
        </svg>
    </div>`
}

const getTextInput = (option) => {
    return `<div class="option text-input ${option.active ? "active" : ""}" data-id="${option.id}">
        <p class="name">${option.label}</p>
        <div class="input">
            <input type="text" placeholder="${option.placeholder || "Enter text"}">
        </div>
    </div>`
}

const getRange = (option) => {
    return `<div class="option quantity" data-id="${option.id}">
        <p class="name">${option.label}</p>
        <div class="controls">
            <button class="less ${option.value == option.min ? 'unable' : ''}">
                <svg width="12" height="2" viewBox="0 0 12 2" fill="none"
                    xmlns="http://www.w3.org/2000/svg">
                    <rect x="0.25" y="0.115234" width="11.5" height="1.76923" rx="0.884615" />
                </svg>
            </button>
            <input type="text" class="value" value="${option.value}">
            <button class="more ${option.value == option.max ? 'unable' : ''}">
                <svg width="12" height="12" viewBox="0 0 12 12" fill="none"
                    xmlns="http://www.w3.org/2000/svg">
                    <path
                        d="M6 11.75C5.76726 11.75 5.57204 11.6711 5.41432 11.5134C5.25661 11.3557 5.17802 11.1608 5.17857 10.9286V6.82143H1.07143C0.838693 6.82143 0.643467 6.74257 0.485753 6.58486C0.328039 6.42714 0.249455 6.23219 0.250003 6C0.250003 5.76726 0.32886 5.57204 0.486574 5.41432C0.644288 5.25661 0.839241 5.17802 1.07143 5.17857H5.17857V1.07143C5.17857 0.838693 5.25743 0.643467 5.41514 0.485753C5.57286 0.328039 5.76781 0.249455 6 0.250003C6.23274 0.250003 6.42796 0.32886 6.58568 0.486574C6.74339 0.644288 6.82198 0.839241 6.82143 1.07143V5.17857H10.9286C11.1613 5.17857 11.3565 5.25743 11.5142 5.41514C11.672 5.57286 11.7505 5.76781 11.75 6C11.75 6.23274 11.6711 6.42796 11.5134 6.58568C11.3557 6.74339 11.1608 6.82198 10.9286 6.82143H6.82143V10.9286C6.82143 11.1613 6.74257 11.3565 6.58486 11.5142C6.42714 11.672 6.23219 11.7505 6 11.75Z" />
                </svg>
            </button>
        </div>
    </div>`
}

const getList = (option) => {
    return `<div class="option list" data-id="${option.id}">
        <p class="name">${option.label}</p>
        <div class="controls">
            <button class="left">
                <svg width="6" height="10" viewBox="0 0 6 10" fill="none"
                    xmlns="http://www.w3.org/2000/svg">
                    <path
                        d="M5.1333 9.0291C5.1333 9.19293 5.07869 9.32472 4.96947 9.42447C4.86025 9.52423 4.73283 9.57447 4.5872 9.5752C4.5508 9.5752 4.42338 9.52059 4.20494 9.41137L0.245742 5.45217C0.154727 5.36116 0.0910162 5.27014 0.0546098 5.17912C0.0182034 5.08811 0 4.98799 0 4.87877C0 4.76955 0.0182034 4.66943 0.0546098 4.57842C0.0910162 4.4874 0.154727 4.39639 0.245742 4.30537L4.20494 0.346176C4.25955 0.291566 4.31889 0.250426 4.38296 0.222757C4.44704 0.195088 4.51512 0.18162 4.5872 0.182347C4.73283 0.182347 4.86025 0.232224 4.96947 0.331977C5.07869 0.43173 5.1333 0.563886 5.1333 0.728442L5.1333 9.0291Z" />
            </svg>
            </button>
            <p class="value">${option.list[0].label}</p>
            <button class="right">
                <svg width="6" height="10" viewBox="0 0 6 10" fill="none"
                    xmlns="http://www.w3.org/2000/svg">
                    <path
                        d="M0.866699 0.850783C0.866699 0.686955 0.921309 0.555163 1.03053 0.45541C1.13975 0.355656 1.26717 0.305416 1.4128 0.304688C1.4492 0.304688 1.57662 0.359297 1.79506 0.468516L5.75426 4.42771C5.84527 4.51873 5.90898 4.60974 5.94539 4.70076C5.9818 4.79178 6 4.89189 6 5.00111C6 5.11033 5.9818 5.21045 5.94539 5.30146C5.90898 5.39248 5.84527 5.4835 5.75426 5.57451L1.79506 9.53371C1.74045 9.58832 1.68111 9.62946 1.61704 9.65713C1.55296 9.68479 1.48488 9.69826 1.4128 9.69754C1.26717 9.69754 1.13975 9.64766 1.03053 9.54791C0.921309 9.44815 0.866699 9.316 0.866699 9.15144L0.866699 0.850783Z" />
                </svg>
            </button>
        </div>`
}

function findOptionById(items, id) {
    id = id.toString();
    for (let item of items) {
        if (item.id === id) {
            return item;
        }

        if (item.type === 'dropdown' && item.options) {
            let found = findOptionById(item.options, id);
            if (found) {
                return found;
            }
        }

        if (item.type === 'list' && item.list) {
            let found = findOptionById(item.list, id);
            if (found) {
                return found;
            }
        }
    }

    return null;
}

const setMenuInfo = (info) => {
    const { title, description } = info;

    $('.context-menu .info .head p').text(title);
    $('.context-menu .info .description').text(description);
}

const setHeader = (header) => {
    const { svgSrc, title, hotkey } = header;

    $('.context-menu .header .img').attr('src', svgSrc);
    $('.context-menu .header .title').text(title);
    $('.context-menu .header .hotkey p').text(hotkey);
}

const setSubmenuHeader = (submenuHeader) => {
    const { mainTitle, subTitle } = submenuHeader;

    $('.context-menu .thread').removeClass('hidden');
    $('.context-menu .thread .main').text(mainTitle);
    $('.context-menu .thread .actual').text(subTitle);
}

const hideSubmenuHeader = () => {
    $('.context-menu .thread').addClass('hidden');
}


const hardcodedItems = [
    {
        id: 'checkbox-1',
        label: 'Checkbox 1',
        type: 'checkbox',
        checked: false
    },
    {
        id: 'checkbox-2',
        label: 'Checkbox 2',
        type: 'checkbox',
        checked: true
    },
    {
        id: 'dropdown-1',
        label: 'Dropdown 1',
        type: 'dropdown',
        options: [
            {
                id: 'checkbox-3',
                label: 'Checkbox 3',
                type: 'checkbox',
                checked: false
            },
            {
                id: 'checkbox-4',
                label: 'Checkbox 4',
                type: 'checkbox',
                checked: true
            },
            {
                id: 'text-input-3',
                label: 'Text Input 3',
                type: 'text-input'
            },
        ]
    },
    {
        id: 'button-1',
        label: 'Button 1',
        type: 'button'
    },
    {
        id: 'text-input-1',
        label: 'Text Input 1',
        type: 'text-input'
    },
    {
        id: 'range-1',
        label: 'Range 1',
        type: 'range',
        min: 2,
        max: 26,
        value: 4
    },
    {
        id: 'list-1',
        label: 'List 1',
        type: 'list',
        list: [
            {
                id: "weapon_sniper",
                label: "Sniper Rifle",
            },
            {
                id: "weapon_rifle",
                label: "Ak 47",
            },
            {
                id: "weapon_pistol",
                label: "Beretta",
            }
        ]
    },
];

/* setOptions(hardcodedItems);
setMenuInfo({
    title: 'Sniper Rifle',
    description: 'A sniper rifle is a category of primary weapons available in Counter-Strike Online.'
});

setHeader({
    svgSrc: './media/icons/Context-menu-icon.svg',
    title: 'Context menu',
    hotkey: 'C'
});
showUi() */

Events.Subscribe("buildContextMenu", function (items) {
    showUi()

    setOptions(items);
    persistentOptions = items
})

Events.Subscribe("ShowNotification", function (data) {
    if (data) {
        showNotification(data.type, data.title, data.message);
        return
    }

    showNotification('info', 'Info', 'Emtpy notification');
    // showNotification(data.type, data.title, data.message);
})

Events.Subscribe("closeContextMenu", function () {
    hideUi()
});

Events.Subscribe("setHeader", function (title) {
    setHeader({
        svgSrc: './media/icons/Context-menu-icon.svg',
        title: title,
        hotkey: 'C'
    });

});

Events.Subscribe("setMenuInfo", function (title, description) {
    setMenuInfo({
        title: title,
        description: description
    });
});

