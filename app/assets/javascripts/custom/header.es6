App.CustomHeader = {
  initialize() {
    $('.js-custom-header-toggle').click(({ currentTarget: el }) => {
      const isExpanded = el.getAttribute('aria-expanded') === 'true';
      const target = document.querySelector(
        `#${el.getAttribute('aria-controls')}`,
      );
      console.log({ target, el });
      if (target) {
        $(target).slideToggle();
        el.setAttribute('aria-expanded', String(!isExpanded));
      }
    });
  },
};
