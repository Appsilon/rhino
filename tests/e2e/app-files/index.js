import Box from './Box';

Rhino.registerReactComponents({ Box });

Shiny.addCustomMessageHandler('toggleDisable', (message) => {
  $(message.id).attr('disabled', message.disable);
});
