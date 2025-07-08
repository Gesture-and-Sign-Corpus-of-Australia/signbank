defmodule Signbank.Workers.Util do
  @moduledoc """
  Utility functions that may be required by multiple workers.
  """
  alias ExAws.S3

  def upload(file) do
    abs = Path.expand(file, Application.fetch_env!(:signbank, :upload_staging))

    # {:ok, :done} or ???? not sure
    abs
    |> S3.Upload.stream_file()
    |> S3.upload(Application.fetch_env!(:signbank, SimpleS3Upload)[:bucket], file)
    |> ExAws.request()

    File.rm(abs)
  end
end
