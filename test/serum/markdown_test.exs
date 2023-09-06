defmodule Serum.MarkdownTest do
  use ExUnit.Case, async: true
  alias Serum.Markdown
  alias Serum.Project

  describe "to_html/2 without pretty URLs" do
    test "converts markdown into HTML" do
      tree =
        md_general()
        |> Markdown.to_html(%Project{base_url: "/test_site/"})
        |> elem(0)
        |> Floki.parse_document!()

      assert [{"h1", _, [h1_text]}] = Floki.find(tree, "h1")
      assert String.trim(h1_text) === "Hello, world!"

      assert [ul, ul, _ul3, ul4, _ul5, _ul6] = Floki.find(tree, "ul")
      assert [img, img] = Floki.find(tree, "img")

      ul4
      |> Floki.find("li")
      |> Enum.each(fn {"li", _, [child]} -> assert is_binary(child) or is_tuple(child) end)
    end

    test "converts markdown into HTML, without applying pretty post URLs" do
      tree =
        md_normal_post_urls()
        |> Markdown.to_html(%Project{base_url: "/test_site/"})
        |> elem(0)
        |> Floki.parse_document!()

      assert [ul, ul] = Floki.find(tree, "ul")
    end
  end

  describe "to_html/2 with pretty post URLs" do
    test "converts markdown into HTML, applying pretty post URLs" do
      tree =
        md_pretty_post_urls()
        |> Markdown.to_html(%Project{base_url: "/test_site/", pretty_urls: :posts})
        |> elem(0)
        |> Floki.parse_document!()

      assert [ul, ul] = Floki.find(tree, "ul")
    end
  end

  defp md_general do
    """
    # Hello, world!

    The quick brown fox jumps over the lazy dog.

    ## Special Syntax Test

    - [Documentation](%page:docs/index)
    - [My Post](%post:2019-01-01-test-post)

    ![Sample picture](%media:images/sample.png)

    ## Special Syntax in HTML

    - [Documentation](%page:docs/index)
    - [My Post](%post:2019-01-01-test-post)

    Mixing markdown and HTML does not work in recent version of Earmark!
    The following code will produce an undesired markup!

    - <a href="%page:docs/index">Documentation</a>
    - <a href="%post:2019-01-01-test-post">My Post</a>

    ![Sample picture](%media:images/sample.png)

    ## These won't be processed

    - %page:docs/index
    - %post:2019-01-01-test-post
    - %media:images/sample.png
    """
  end

  defp md_normal_post_urls do
    """
    - [My Post](%post:2019-01-01-test-post)

    - [My Post](/test_site/posts/2019-01-01-test-post.html)
    """
  end

  defp md_pretty_post_urls do
    """
    - [My Post](%post:2019-01-01-test-post)

    - [My Post](/test_site/posts/2019-01-01-test-post)
    """
  end
end
