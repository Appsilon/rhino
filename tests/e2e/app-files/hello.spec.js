describe('Say Hello', () => {
  beforeEach(() => {
    cy.visit('/');
  });


  it('should have an empty input, disabled button, and no message on start up', () => {
    cy.get('#app-hello-say_hello').should('be.disabled');
    cy.get('#app-hello-name').should('have.value', '');
    cy.get('#app-hello-message').should('not.have.text');
  });

  it('should enable button on input and display message on click', () => {
    const inputName = 'Rhino';
    cy.get('#app-hello-name').type(inputName);

    cy.get('#app-hello-say_hello').should('not.be.disabled');
    cy.get('#app-hello-say_hello').click();

    cy.get('#app-hello-message').should('have.text', `Hello, ${inputName}!`);
  });

  it('should disable button when text is cleared', () => {
    const inputName = 'Rhino';
    cy.get('#app-hello-name').type(inputName);

    cy.get('#app-hello-say_hello').should('not.be.disabled');
    cy.get('#app-hello-say_hello').click();

    cy.get('#app-hello-name').clear();
    cy.get('#app-hello-say_hello').should('be.disabled');
  });
})
