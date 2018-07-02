module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)
  GetResult    = Struct.new(:success?, :expenses)

  class Ledger
    def record(expense)

    end

    def expenses_on(date)

    end
  end
end