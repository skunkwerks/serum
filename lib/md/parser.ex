defmodule Serum.Md.Parser do
  defmodule Tag do
    @moduledoc false
    @behaviour Md.Transforms

    @href "/tags/"

    @impl Md.Transforms
    def apply(_md, text) do
      tag = String.downcase(text)
      href = @href <> URI.encode_www_form(tag)
      {:a, %{class: "tag", "data-tag": tag, href: href}, [text]}
    end
  end

  @serum_syntax Md.Parser.Syntax.merge(Md.Parser.Syntax.Default.syntax(), %{})

  use Md.Parser, syntax: @serum_syntax
  import Md.Parser.DSL

  comment("<!--", %{closing: "-->"})
  magnet("%", %{transform: Tag, terminators: [:ascii_punctuation]})
  # linewrap true
end
