Shiny.addCustomMessageHandler('toggleDisable', (message) => {
  $(message.id).attr('disabled', message.disable);
});
