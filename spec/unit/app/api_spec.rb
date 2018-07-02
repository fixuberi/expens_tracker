require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    def json_response
      JSON.parse(last_response.body)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context "when the expense is successfully recorded" do

        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
                               .with(expense)
                               .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)


          expect(json_response).to include('expense_id' => 417)
        end


        it 'responds with a 200' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context "when the expense fails validation" do
        let(:expense) { {'some' => 'data'} }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error of message' do
          post '/expenses', JSON.generate(expense)

          expect(json_response).to include('error' => 'Expense incomplete')
        end
        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe "GET /expenses/:date" do

      let(:expenses) { [{'some' => 'data'}, {'some' => 'data'}] }
      let(:date) { '2017-06-12' }

      context 'when expenses exist on the given date' do

       before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(GetResult.new(true, expenses))
        end

        it 'returns expense records as JSON' do
          get "/expenses/#{date}"
          expect(json_response).to match_array(expenses)
        end
        it 'responds with a 200' do
          get "expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end
      context 'when there are no expenses on the given date' do

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(GetResult.new(false, expenses))
        end

        it 'returns the empty array' do
          get "/expenses/#{date}"
          expect(json_response).to eq([])
        end
        it 'responds with a 200' do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end