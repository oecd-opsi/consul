App.CustomNewsletterForm = {
  initialize() {
    $('.js-newsletter-form').submit((e) => {
      e.preventDefault();
      const { target: form } = e;
      $('.js-newsletter-form-info').hide();
      const url =
        form.getAttribute('action').replace('/post?u=', '/post-json?u=') +
        '&c=?';
      $.ajax({
        url: url + '&' + $(form).serialize(),
        type: 'GET',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8',
        success(...args) {
          // trigger logic from prevent_double_submission.js
          $(form).trigger('ajax:success', args);

          App.CustomNewsletterForm.success(form, ...args);
        },

        error() {
          $('.js-newsletter-form-info').text(
            'Unexpected error occurred. Please try again in a few minutes.',
          );
          $('.js-newsletter-form-info').show();
        },
      });
    });
  },

  success(form, resp) {
    if (resp.result == 'success') {
      $('.js-newsletter-form-info').text(resp.msg);
      $('.js-newsletter-form-info').show();
      $('.js-newsletter-form').each(function () {
        this.reset();
      });
    } else {
      if (resp.msg === 'captcha') {
        var url = $(form).attr('action');
        var parameters = $.param(resp.params);
        url = url.split('?')[0];
        url += '?';
        url += parameters;
        window.open(url);
      }

      const msg =
        resp.msg.replace(/^\d+ *- */, '') ||
        'Unexpected error occurred. Please try again in a few minutes.';

      $('.js-newsletter-form-info').show();
      $('.js-newsletter-form-info').text(msg);
    }
  },
};
