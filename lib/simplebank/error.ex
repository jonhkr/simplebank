defmodule SimpleBank.Error do
  
  @enforce_keys [:message]
  defstruct message: nil
end