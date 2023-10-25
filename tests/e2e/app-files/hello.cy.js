describe('Say Hello', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  it('should save trace log in log.txt', () => {
    const filePath = '../log.txt';

    cy.readFile(filePath)
      .then(fileContents => {
        expect(fileContents).to.match(/^TRACE.+This is a test/);
      });
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

  it('should style elements', () => {
    const inputName = 'Rhino';
    cy.get('#app-hello-name').type(inputName);
    cy.get('#app-hello-say_hello').click();

    cy.get('.input-and-click')
      .should('have.css', 'display', 'inline-flex');

    cy.get('#app-hello-say_hello')
      .should('have.css', 'color', 'rgb(255, 255, 255)')
      // check if border: none
      .and('have.css', 'border-width', '0px')
      .and('have.css', 'border-style', 'none')
      .and('have.css', 'border-color', 'rgb(255, 255, 255)')
      .and('have.css', 'background-color', 'rgb(0, 153, 249)');

    cy.get('#app-hello-message')
      .should('have.css', 'display', 'flex')
      .and('have.css', 'align-items', 'center')
      .and('have.css', 'justify-content', 'center');
  });

  it('should work with React components', () => {
    cy.get('#app-box button').click();
    cy.get('#app-box p').contains('React works!');
  })
})
