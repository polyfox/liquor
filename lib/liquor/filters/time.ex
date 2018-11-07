defmodule Liquor.Filters.Time do
  @moduledoc """
  Specialized module for filtering date fields
  """
  import Ecto.Query

  def apply_filter(query, :match, key, value) do
  end

  def apply_filter(query, :unmatch, key, value) do
  end

  def apply_filter(query, :==, key, value) do
  end

  def apply_filter(query, :!=, key, value) do
  end

  def apply_filter(query, :>=, key, value) do
  end

  def apply_filter(query, :<=, key, value) do
  end

  def apply_filter(query, :>, key, value) do
  end

  def apply_filter(query, :<, key, value) do
  end
end
