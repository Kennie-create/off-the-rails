require 'rails_helper'

RSpec.describe Api::V1::ReviewsController do
  let!(:park1) { Park.create(
    name: "Disney",
    description: "Happiest place on Earth!",
    city: "Boston",
    country: "USA",
    park_photo: File.open(File.join(
      Rails.root, '/public/images_seed/disney_land.jpg'
      ))
    )}
  let!(:user1) { FactoryBot.create(:user) }
  let!(:review1) {
    {
      review: {
        title: "This is awesome",
        body: "Because I said so anything anything anything.",
        rating: 5
      },
      park_id: park1.id
    }
  }

  describe "POST#create" do
    context "Post of review was successful" do
      let!(:park1) { Park.create(
        name: "Disney",
        description: "Happiest place on Earth!",
        city: "Boston",
        country: "USA",
        park_photo: File.open(File.join(
          Rails.root, '/public/images_seed/disney_land.jpg'
          ))
      )}
      let!(:user1) { FactoryBot.create(:user) }
      let!(:review1) {
        {
          review: {
            title: "This is awesome",
            body: "Because I said so and I am the very best there is.",
            rating: 5
          },
          park_id: park1.id
        }
      }

      it "should persist in the database" do
        sign_in user1
        previous_count = Review.count
        post :create, params: review1, format: :json
        next_count = Review.count

        expect(response.status).to eq(200)
        expect(response.content_type).to eq("application/json")
        expect(next_count).to be previous_count + 1
      end

      it "returns the review that was just created" do
        sign_in user1
        post :create, params: review1, format: :json
        returned_json = JSON.parse(response.body)

        expect(returned_json["review"]["title"]).to eq "This is awesome"
        expect(returned_json["review"]["body"]).to eq "Because I said so and I am the very best there is."
        expect(returned_json["review"]["rating"]).to eq 5
      end
    end

    context "Post was unsuccessful" do
      let!(:park2) { Park.create(
        name: "Universal",
        description: "Second happiest place on Earth!",
        city: "Boston",
        country: "USA",
        park_photo: File.open(File.join(
          Rails.root, '/public/images_seed/disney_land.jpg'
        ))
      )}
      let!(:bad_review) {
        {
          review: {
            title: "This is awesome"
          },
          park_id: park2.id
        }
      }
      let!(:user1) { FactoryBot.create(:user) }

      it "doesn't save to the database" do
        sign_in user1
        previous_count = Review.count
        post :create, params: bad_review, format: :json
        next_count = Review.count

        expect(next_count).to be previous_count
      end

      it "should return errors" do
        sign_in user1
        post :create, params: bad_review, format: :json
        returned_json = JSON.parse(response.body)
        expect(returned_json.include?("Body can't be blank")).to be true
        expect(returned_json.include?("Rating can't be blank")).to be true
      end
    end
  end

  describe "PATCH#update" do
    context "Post of updated review was succesful" do
      it "should change in the database" do
        sign_in user1
        post :create, params: review1, format: :json
        old_review = JSON.parse(response.body)["review"]

        updated_review = {
          review: {
            title: "This is slightly less awesome",
            body: "Because we all say so and I am the best so i know more",
            rating: 4
          },
          id: old_review["id"],
          park_id: old_review["park"]["id"]
        }

        put :update, params: updated_review, format: :json
        review = Review.find(old_review["id"])

        expect(review.title).to eq(updated_review[:review][:title])
        expect(review.title).to_not eq(old_review["title"])
      end

      it "returns the review that was updated" do
        sign_in user1
        post :create, params: review1, format: :json
        old_review = JSON.parse(response.body)["review"]

        updated_review = {
          review: {
            title: "This is slightly less awesome",
            body: "Because we all say so  I am the best so i know more",
            rating: 4
          },
          id: old_review["id"],
          park_id: old_review["park"]["id"]
        }

        put :update, params: updated_review, format: :json
        returned_review = JSON.parse(response.body)["review"]

        expect(returned_review["title"]).to eq(updated_review[:review][:title])
        expect(returned_review["title"]).to_not eq(old_review["title"])
      end
    end
  end

  describe "DELETE#destroy" do
    context "Use delete method to destroy review succesfully" do
      it "review is removed from the database" do
        sign_in user1
        post :create, params: review1, format: :json
        returned_json = JSON.parse(response.body)["review"]

        delete_params = {
          id: returned_json["id"],
          park_id: returned_json["park"]["id"]
        }

        old_count = Review.all.length
        delete :destroy, params: delete_params, format: :json
        new_count = Review.all.length

        expect(new_count).to_not eq(old_count)
        expect(new_count).to eq(old_count - 1)
      end

      it "returns the park associated with the deleted review" do
        sign_in user1
        post :create, params: review1, format: :json
        returned_json = JSON.parse(response.body)["review"]

        delete_params = {
          id: returned_json["id"],
          park_id: returned_json["park"]["id"]
        }

        delete :destroy, params: delete_params, format: :json
        returned_park = JSON.parse(response.body)["park"]

        expect(returned_park["title"]).to eq(returned_json["park"]["title"])
      end
    end
  end
end
