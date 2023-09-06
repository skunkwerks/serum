defmodule Serum.Build.FileProcessor.PostTest do
  use ExUnit.Case, async: true
  require Serum.TestHelper
  import Serum.TestHelper, only: :macros
  alias Serum.Build.FileProcessor.Post, as: PostProcessor
  alias Serum.Project
  alias Serum.Project.Loader, as: ProjectLoader

  setup_all do
    {:ok, proj} = ProjectLoader.load(fixture("proj/good"), "/path/to/dest/")

    {:ok, [proj: proj]}
  end

  describe "process_posts/2 with preety URLs disabled" do
    test "good post", ctx do
      {:ok, result} = process("posts/good-post.md", ctx.proj)
      {[post], [compact_post]} = result

      assert %{
               title: "Test Post",
               date: "2019-01-01",
               raw_date: {{2019, 1, 1}, {12, 34, 56}},
               tags: [
                 %Serum.Tag{name: "Elixir", list_url: "/test-site/tags/Elixir"},
                 %Serum.Tag{name: "Proyectos", list_url: "/test-site/tags/Proyectos"},
                 %Serum.Tag{name: "Serum", list_url: "/test-site/tags/Serum"},
                 %Serum.Tag{name: "aleksei", list_url: "/test-site/tags/aleksei"},
                 %Serum.Tag{name: "home", list_url: "/test-site/tags/home"},
                 %Serum.Tag{name: "posts", list_url: "/test-site/tags/posts"},
                 %Serum.Tag{name: "tag1", list_url: "/test-site/tags/tag1"},
                 %Serum.Tag{name: "tag2", list_url: "/test-site/tags/tag2"},
                 %Serum.Tag{name: "test_fixtures", list_url: "/test-site/tags/test_fixtures"}
               ],
               url: "/test-site/posts/good-post.html",
               output: "/path/to/dest/posts/good-post.html"
             } = post

      assert_compact(compact_post)
    end

    test "good, date without time", ctx do
      {:ok, result} = process("posts/good-alternative-date.md", ctx.proj)
      {[post], [compact_post]} = result

      assert %{
               title: "Test Post",
               date: "2019-01-01",
               raw_date: {{2019, 1, 1}, {0, 0, 0}},
               tags: [
                 %Serum.Tag{name: "Elixir", list_url: "/test-site/tags/Elixir"},
                 %Serum.Tag{name: "Proyectos", list_url: "/test-site/tags/Proyectos"},
                 %Serum.Tag{name: "Serum", list_url: "/test-site/tags/Serum"},
                 %Serum.Tag{name: "aleksei", list_url: "/test-site/tags/aleksei"},
                 %Serum.Tag{name: "home", list_url: "/test-site/tags/home"},
                 %Serum.Tag{name: "posts", list_url: "/test-site/tags/posts"},
                 %Serum.Tag{name: "tag3", list_url: "/test-site/tags/tag3"},
                 %Serum.Tag{name: "tag4", list_url: "/test-site/tags/tag4"},
                 %Serum.Tag{name: "test_fixtures", list_url: "/test-site/tags/test_fixtures"}
               ],
               output: "/path/to/dest/posts/good-alternative-date.html"
             } = post

      assert_compact(compact_post)
    end

    test "good, without tags", ctx do
      {:ok, result} = process("posts/good-minimal-header.md", ctx.proj)
      {[post], [compact_post]} = result

      assert %{
               title: "Test Post",
               date: "2019-01-01",
               raw_date: {{2019, 1, 1}, {0, 0, 0}},
               tags: [
                 %Serum.Tag{name: "Elixir", list_url: "/test-site/tags/Elixir"},
                 %Serum.Tag{name: "Proyectos", list_url: "/test-site/tags/Proyectos"},
                 %Serum.Tag{name: "Serum", list_url: "/test-site/tags/Serum"},
                 %Serum.Tag{name: "aleksei", list_url: "/test-site/tags/aleksei"},
                 %Serum.Tag{name: "home", list_url: "/test-site/tags/home"},
                 %Serum.Tag{name: "posts", list_url: "/test-site/tags/posts"},
                 %Serum.Tag{name: "test_fixtures", list_url: "/test-site/tags/test_fixtures"}
               ],
               output: "/path/to/dest/posts/good-minimal-header.html"
             } = post

      assert_compact(compact_post)
    end

    # [AM]
    #   test "fail on bad posts", ctx do
    #     files =
    #       fixture("posts")
    #       |> Path.join("bad-*.md")
    #       |> Path.wildcard()
    #       |> Enum.map(&%Serum.File{src: &1})
    #       |> Enum.map(&Serum.File.read/1)
    #       |> Enum.map(fn {:ok, file} -> file end)

    #     {:error, {_, errors}} = PostProcessor.process_posts(files, ctx.proj)

    #     assert length(errors) === length(files)
    #   end
  end

  describe "process_posts/2 with preety URLs enabled" do
    setup ctx, do: {:ok, [proj: %Project{ctx.proj | pretty_urls: :posts}]}

    test "sets URL and output file path suitable for preety URLs", ctx do
      {:ok, result} = process("posts/good-post.md", ctx.proj)
      {[post], [compact_post]} = result

      assert %{
               title: "Test Post",
               date: "2019-01-01",
               raw_date: {{2019, 1, 1}, {12, 34, 56}},
               tags: [
                 %Serum.Tag{name: "Elixir", list_url: "/test-site/tags/Elixir"},
                 %Serum.Tag{name: "Proyectos", list_url: "/test-site/tags/Proyectos"},
                 %Serum.Tag{name: "Serum", list_url: "/test-site/tags/Serum"},
                 %Serum.Tag{name: "aleksei", list_url: "/test-site/tags/aleksei"},
                 %Serum.Tag{name: "home", list_url: "/test-site/tags/home"},
                 %Serum.Tag{name: "posts", list_url: "/test-site/tags/posts"},
                 %Serum.Tag{name: "tag1", list_url: "/test-site/tags/tag1"},
                 %Serum.Tag{name: "tag2", list_url: "/test-site/tags/tag2"},
                 %Serum.Tag{name: "test_fixtures", list_url: "/test-site/tags/test_fixtures"}
               ],
               url: "/test-site/posts/good-post",
               output: "/path/to/dest/posts/good-post/index.html"
             } = post

      assert_compact(compact_post)
    end
  end

  defp process(fixture_path, proj) do
    {:ok, file} = Serum.File.read(%Serum.File{src: fixture(fixture_path)})

    PostProcessor.process_posts([file], proj)
  end

  defp assert_compact(map) do
    refute map[:__struct__]
    refute map[:file]
    refute map[:html]
    refute map[:output]
    assert map.type === :post
  end
end
