# TestedCell

A Tested Kino SmartCell for Livebook.

Run tests on an Elixir Cell without revealing the tests or writing a significant amount of ExUnit boilerplate.

## Installation

Add the dependency in your Livebook setup section. This project relies on [Kino](https://github.com/livebook-dev/kino).

```elixir
Mix.install([{:kino, "~> 0.6.2"}, {:tested_cell, github: "BrooklinJazz/tested_cell"}])
```

## Usage

Run [notebooks/example.livemd](https://github.com/BrooklinJazz/tested_cell/blob/main/notebooks/example.livemd) in Livebook for practical examples.

`TestedCell` displays text editors for writing assertions and a solution hint.

![image](https://user-images.githubusercontent.com/14877564/181716751-c98c8af4-7151-4de6-83d3-5d958a3fc97e.png)

Which can be disabled.

![image](https://user-images.githubusercontent.com/14877564/181716493-1b28a439-15bc-4a11-a7ef-817ff0fbef8f.png)

Solution hints appear after 3 attempts.

![image](https://user-images.githubusercontent.com/14877564/181724809-30365bfc-9001-4a31-b39b-09a72c312cbe.png)
