require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe RecipientListsController, type: :controller do

  let(:school) { School.create!(name: 'School') }

  # This should return the minimal set of attributes required to create a valid
  # RecipientList. As you add validations to RecipientList, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      school_id: school.id,
      recipient_ids: '1,2,3',
      name: 'Parents',
      description: 'List of parents.'
    }
  }

  let(:invalid_attributes) {
    {school_id: school.id, name: 'Empty List', recipient_ids: ''}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RecipientListsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all recipient_lists as @recipient_lists" do
      recipient_list = RecipientList.create! valid_attributes
      get :index, params: {school_id: school.to_param}, session: valid_session
      expect(assigns(:recipient_lists)).to eq([recipient_list])
    end
  end

  describe "GET #show" do
    it "assigns the requested recipient_list as @recipient_list" do
      recipient_list = RecipientList.create! valid_attributes
      get :show, params: {school_id: school.to_param, id: recipient_list.to_param}, session: valid_session
      expect(assigns(:recipient_list)).to eq(recipient_list)
    end
  end

  describe "GET #new" do
    it "assigns a new recipient_list as @recipient_list" do
      get :new, params: {school_id: school.to_param}, session: valid_session
      expect(assigns(:recipient_list)).to be_a_new(RecipientList)
    end
  end

  describe "GET #edit" do
    it "assigns the requested recipient_list as @recipient_list" do
      recipient_list = RecipientList.create! valid_attributes
      get :edit, params: {school_id: school.to_param, id: recipient_list.to_param}, session: valid_session
      expect(assigns(:recipient_list)).to eq(recipient_list)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new RecipientList" do
        expect {
          post :create, params: {school_id: school.to_param, recipient_list: valid_attributes}, session: valid_session
        }.to change(RecipientList, :count).by(1)
      end

      it "assigns a newly created recipient_list as @recipient_list" do
        post :create, params: {school_id: school.to_param, recipient_list: valid_attributes}, session: valid_session
        expect(assigns(:recipient_list)).to be_a(RecipientList)
        expect(assigns(:recipient_list)).to be_persisted
      end

      it "redirects to the created recipient_list" do
        post :create, params: {school_id: school.to_param, recipient_list: valid_attributes}, session: valid_session
        expect(response).to redirect_to(school_recipient_list_path(school, RecipientList.last))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved recipient_list as @recipient_list" do
        post :create, params: {school_id: school.to_param, recipient_list: invalid_attributes}, session: valid_session
        expect(assigns(:recipient_list)).to be_a_new(RecipientList)
      end

      it "re-renders the 'new' template" do
        post :create, params: {school_id: school.to_param, recipient_list: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {recipient_ids: '3,4,5'}
      }

      it "updates the requested recipient_list" do
        recipient_list = RecipientList.create! valid_attributes
        put :update, params: {school_id: school.to_param, id: recipient_list.to_param, recipient_list: new_attributes}, session: valid_session
        recipient_list.reload
        expect(recipient_list.recipient_ids).to eq('3,4,5')
      end

      it "assigns the requested recipient_list as @recipient_list" do
        recipient_list = RecipientList.create! valid_attributes
        put :update, params: {school_id: school.to_param, id: recipient_list.to_param, recipient_list: valid_attributes}, session: valid_session
        expect(assigns(:recipient_list)).to eq(recipient_list)
      end

      it "redirects to the recipient_list" do
        recipient_list = RecipientList.create! valid_attributes
        put :update, params: {school_id: school.to_param, id: recipient_list.to_param, recipient_list: valid_attributes}, session: valid_session
        expect(response).to redirect_to(school_recipient_list_url(school, recipient_list))
      end
    end

    context "with invalid params" do
      it "assigns the recipient_list as @recipient_list" do
        recipient_list = RecipientList.create! valid_attributes
        put :update, params: {school_id: school.to_param, id: recipient_list.to_param, recipient_list: invalid_attributes}, session: valid_session
        expect(assigns(:recipient_list)).to eq(recipient_list)
      end

      it "re-renders the 'edit' template" do
        recipient_list = RecipientList.create! valid_attributes
        put :update, params: {school_id: school.to_param, id: recipient_list.to_param, recipient_list: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested recipient_list" do
      recipient_list = RecipientList.create! valid_attributes
      expect {
        delete :destroy, params: {school_id: school.to_param, id: recipient_list.to_param}, session: valid_session
      }.to change(RecipientList, :count).by(-1)
    end

    it "redirects to the recipient_lists list" do
      recipient_list = RecipientList.create! valid_attributes
      delete :destroy, params: {school_id: school.to_param, id: recipient_list.to_param}, session: valid_session
      expect(response).to redirect_to(school)
    end
  end

end
