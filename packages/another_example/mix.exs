defmodule AnotherExample.MixProject do
  use Mix.Project

  def project do
    [
      app: :another_example,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Another example package for the Artifix registry template",
      package: [
        maintainers: ["Coby Benveniste"],
        licenses: ["MIT"],
        links: %{},
        files: ["lib", "mix.exs", "README*"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
