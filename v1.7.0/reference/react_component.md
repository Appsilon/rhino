# React components

Declare the React components defined in your app.

## Usage

``` r
react_component(name)
```

## Arguments

- name:

  The name of the component.

## Value

A function representing the component.

## Details

There are three steps to add a React component to your Rhino
application:

1.  Define the component using JSX and register it with
    `Rhino.registerReactComponents()`.

2.  Declare the component in R with `rhino::react_component()`.

3.  Use the component in your application.

Please refer to the [Tutorial: Use React in
Rhino](https://appsilon.github.io/rhino/articles/tutorial/use-react-in-rhino.html)
to learn about the details.

## Examples

``` r
# Declare the component.
TextBox <- react_component("TextBox")

# Use the component.
ui <- TextBox("Hello!", font_size = 20)
```
