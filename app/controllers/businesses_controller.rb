class BusinessesController < ApplicationController

	def initialize
		super
		@var = BusinessDecorator.new
	end

	def index
		@var.title = t('cmn_sentence.listTitle', model: @var.model_name)
		if request.post?
			cond_list = {name: CondEnum::LIKE, business_type_id: CondEnum::EQ}
			free_word = {keyword: [:descriptions, :welcome]}
			cond_set = self.createCondition(params, cond_list, free_word)
			@businesses = Business.where(cond_set[:cond_arr])
			@var.search_cond = cond_set[:cond_param]
		else
			@var.search_cond = nil
		end

		@businesses = Business.all if @business.nil?
		@var.view_counter = @businesses.count
	end

	# ?office_id=?で親の事業所idがわたる
	def new
		@var.title = t('cmn_sentence.newTitle', model: t('cmn_dict.business'))
		@business = Business.new
		return insert_new_business(params) if request.post?
		@business.init_new_instance(params)

	end

	def edit

	end

	def edit_own

	end

	def contact_list

	end

	private

		def insert_new_business(params)
			begin
				Business.transaction do
					@business.attributes = Business.business_params(params, :businees)
					@business.save!
					respond_to do |format|
						format.html {redirect_to(action: 'edit', id: @business.id)}
						format.json {render :show, status: :created, location: @business}
					end
				end
			rescue => e
				flash.now[:alert] = e.message
				respond_to do |format|
					format.html {render 'new'}
					format.json {render json: format, status: :unprocessable_entity}
				end
			end

		end

end
