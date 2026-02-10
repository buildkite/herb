# frozen_string_literal: true

require_relative "../test_helper"

module Lexer
  class ERBTest < Minitest::Spec
    include SnapshotUtils

    test "erb <% %>" do
      assert_lexed_snapshot(%(<% 'hello world' %>))
    end

    test "erb <%= %>" do
      assert_lexed_snapshot(%(<%= "hello world" %>))
    end

    test "erb <%- %>" do
      assert_lexed_snapshot(%(<%- "Test" %>))
    end

    test "erb <%- -%>" do
      assert_lexed_snapshot(%(<%- "Test" -%>))
    end

    test "erb <%# %>" do
      assert_lexed_snapshot(%(<%# "Test" %>))
    end

    test "erb <%% %%>" do
      assert_lexed_snapshot(%(<%% "Test" %%>))
    end

    test "erb <%%= %%>" do
      assert_lexed_snapshot(%(<%%= "Test" %%>))
    end

    test "erb <% =%>" do
      assert_lexed_snapshot(%(<% "Test" =%>))
    end

    test "erb <%= =%>" do
      assert_lexed_snapshot(%(<%= "Test" =%>))
    end

    test "erb output inside HTML attribute value" do
      assert_lexed_snapshot(%(<article id="<%= dom_id(article) %>"></article>))
    end

    test "erb output inside HTML attribute value with value before" do
      assert_lexed_snapshot(%(<div class="bg-black <%= "text-white" %>"></div>))
    end

    test "erb output inside HTML attribute value with value before and after" do
      assert_lexed_snapshot(%(<div class="bg-black <%= "text-white" %> cursor-pointer"></div>))
    end

    test "erb output inside HTML attribute value with value and after" do
      assert_lexed_snapshot(%(<div class="<%= "text-white" %> bg-black"></div>))
    end

    test "multi-line erb content" do
      assert_lexed_snapshot(<<~HTML)
        <%=
          hello
        %>
      HTML
    end

    test "multi-line erb content with complex ruby" do
      assert_lexed_snapshot(<<~HTML)
        <%=
          if condition
            "value1"
          else
            "value2"
          end
        %>
      HTML
    end

    test "multi-line erb silent tag" do
      assert_lexed_snapshot(<<~HTML)
        <%
          x = 1
          y = 2
        %>
      HTML
    end

    test "erb tag followed by literal closing delimiter" do
      assert_lexed_snapshot(%(<% content %> %>))
    end

    # === Heredoc support ===

    test "erb heredoc with %> inside body" do
      assert_lexed_snapshot(<<~'HTML')
        <% x = <<~HEREDOC
          some content %> here
        HEREDOC
        %>
      HTML
    end

    test "erb heredoc bare identifier" do
      assert_lexed_snapshot(<<~'HTML')
        <% x = <<HEREDOC
        content with %> inside
        HEREDOC
        %>
      HTML
    end

    test "erb heredoc with dash (<<-)" do
      assert_lexed_snapshot(<<~'HTML')
        <% x = <<-HEREDOC
          content with %> inside
          HEREDOC
        %>
      HTML
    end

    test "erb heredoc with squiggly (<<~)" do
      assert_lexed_snapshot(<<~'HTML')
        <% x = <<~HEREDOC
          content with %> inside
        HEREDOC
        %>
      HTML
    end

    test "erb heredoc with double-quoted delimiter" do
      assert_lexed_snapshot(<<~'HTML')
        <% x = <<"HEREDOC"
        content with %> inside
        HEREDOC
        %>
      HTML
    end

    test "erb heredoc with single-quoted delimiter" do
      assert_lexed_snapshot(<<~'HTML')
        <% x = <<'HEREDOC'
        content with %> inside
        HEREDOC
        %>
      HTML
    end

    # === String literals with %> ===

    test "erb double-quoted string with %> inside" do
      assert_lexed_snapshot(%(<%= "hello %> world" %>))
    end

    test "erb single-quoted string with %> inside" do
      assert_lexed_snapshot(%(<%= 'hello %> world' %>))
    end

    test "erb string with escaped quote before %>" do
      assert_lexed_snapshot(%(<%= "hello \\" %> world" %>))
    end

    # === Ruby comments ===

    test "erb ruby comment does not skip %> closer" do
      assert_lexed_snapshot(<<~'HTML')
        <% x = 1 # this is a comment with %> in it
        %>
      HTML
    end

    test "erb ruby comment at end of content" do
      assert_lexed_snapshot(%(<% x = 1 # comment %>))
    end

    # === ERB comment tags ===

    test "erb comment does not parse ruby strings" do
      assert_lexed_snapshot(%(<%# "unclosed string %>))
    end

    test "erb comment does not parse heredocs" do
      assert_lexed_snapshot(<<~'HTML')
        <%# <<~HEREDOC
        %>
      HTML
    end

    test "erb comment with %> closes normally" do
      assert_lexed_snapshot(%(<%# this is a comment %>))
    end
  end
end
