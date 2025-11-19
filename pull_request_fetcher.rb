#!/usr/bin/env ruby
# frozen_string_literal: true

require 'octokit'
require 'csv'
require 'uri'
require 'date'
require 'fileutils'
require 'dotenv/load'

class PullRequestFetcher
  def initialize(author, repo_url, start_date, end_date = nil)
    @author         = author
    @repo_full_name = extract_repo_full_name(repo_url)
    @start_date     = Date.parse(start_date)
    @end_date       = end_date.nil? ? nil : Date.parse(end_date)

    FileUtils.mkdir_p("tmp")
    timestamp       = Time.now.strftime("%Y%m%d_%H%M%S")
    @output_file    = "tmp/pull_request_fetcher_#{timestamp}.csv"

    @client = create_client
  end

  # メイン処理
  def run
    prs      = fetch_prs
    filtered = filter_by_date(prs)
    export_csv(filtered, @output_file)
    puts "Done! => #{@output_file}"
  end

  private

  # -------------------------------
  # .env から読み込んだ GITHUB_TOKEN 使用
  # -------------------------------
  def create_client
    token = ENV["GITHUB_TOKEN"]
    raise "ERROR: GITHUB_TOKEN が .env に設定されていません。" if token.nil? || token.empty?

    client = Octokit::Client.new(access_token: token)
    client.auto_paginate = true
    client
  end

  # -------------------------------
  # URL から owner/repo 名を抽出
  # -------------------------------
  def extract_repo_full_name(url)
    uri = URI.parse(url)
    segments = uri.path.split("/").reject(&:empty?)
    raise "ERROR: 不正なリポジトリURLです: #{url}" unless segments.size >= 2

    segments[0..1].join("/")
  end

  # -------------------------------
  # GitHub の PR を author 指定で検索
  # -------------------------------
  def fetch_prs
    query = "repo:#{@repo_full_name} author:#{@author} type:pr"
    puts "Query: #{query}"

    result = @client.search_issues(query, per_page: 100)
    result.items
  rescue => e
    raise "GitHub API エラー: #{e.class} - #{e.message}"
  end

  # -------------------------------
  # 作成日でフィルタ
  # -------------------------------
  def filter_by_date(items)
    items.select do |item|
      created = Date.parse(item.created_at.to_s)
      next false if created < @start_date
      next false if @end_date && created > @end_date
      true
    end
  end

  # -------------------------------
  # 個別 PR 詳細取得
  # -------------------------------
  def fetch_pr_detail(item)
    number = item.number
    @client.pull_request(@repo_full_name, number)
  rescue => e
    warn "WARN: PR ##{number} の取得に失敗: #{e.message}"
    nil
  end

  # -------------------------------
  # ステータス（open / closed / merged）
  # -------------------------------
  def pr_status(pr)
    return "merged" if pr.merged_at
    pr.state
  end

  # -------------------------------
  # JST で YYYY/MM/DD にフォーマット
  # -------------------------------
  def format_jst(date)
    return nil if date.nil?
    # GitHub API は基本 UTC。+09:00 に変換して日付だけ出力
    date.getlocal("+09:00").strftime("%Y/%m/%d")
  end

  # -------------------------------
  # CSV へ出力
  # -------------------------------
  def export_csv(items, output)
    CSV.open(output, "w", headers: true) do |csv|
      csv << %w[
        repository_name
        pr_url
        status
        created_at
        opened_at
        closed_at
        conversation_count
      ]

      items.each.with_index(1) do |item, idx|
        pr = fetch_pr_detail(item)
        next unless pr

        csv << [
          @repo_full_name,
          pr.html_url,
          pr_status(pr),
          format_jst(pr.created_at), # created_at (JST, YYYY/MM/DD)
          format_jst(pr.created_at), # opened_at (同じく created_at を OPEN 日とみなす)
          format_jst(pr.closed_at),  # closed_at
          pr.comments.to_i + pr.review_comments.to_i
        ]

        puts "Processed (#{idx}/#{items.size}): #{pr.html_url}"
      end
    end
  end
end

# ===========================================
# 実行部分
# ===========================================

if ARGV.size < 3
  warn "Usage: ruby pull_request_fetcher.rb AUTHOR REPO_URL START_DATE [END_DATE]"
  warn "例: ruby pull_request_fetcher.rb koba-masa https://github.com/koba-masa/play_with_github 2024-01-01 2024-12-31"
  exit 1
end

author     = ARGV[0]
repo_url   = ARGV[1]
start_date = ARGV[2]
end_date   = ARGV[3]

fetcher = PullRequestFetcher.new(author, repo_url, start_date, end_date)
fetcher.run
