# Flutter Test App

A Flutter test app using Clean Architecture, MVVM and [Stacked](https://stacked.filledstacks.com/), following [this](https://www.figma.com/file/HehRywstjGipJMcMZqwJqG/Carrito?node-id=0-1&t=o2241PkGk8jhRUqE-0) design and using [this](https://dummyjson.com/docs/products) API.

Basic functionalities:
- Show a paginated list with search.
- Show details of a product.
- Handle a cart locally. For this the app uses the [sqflite](https://pub.dev/packages/sqflite) package to store the data.
  