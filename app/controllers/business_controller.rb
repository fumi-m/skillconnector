class BusinessController < ApplicationController

  def initialize
    super
    @var = BusinessDecorator.new
    @var.link = {
      I18n.t("cmn_sentence.listTitle", model: Business.model_name.human) => {controller: "business", action: "index"},
      I18n.t("cmn_sentence.newTitle", model: Business.model_name.human) => {controller: "business", action: "new"},
      I18n.t('cmn_sentence.listTitle', model: Office.model_name.human) => {controller: 'office', action: 'index'},
      I18n.t('cmn_sentence.listTitle', model: Engineer.model_name.human) => {controller: 'engineer', action: 'index'},
      I18n.t('cmn_sentence.listTitle', model: Proposal.model_name.human) => {controller: 'proposal', action: 'index'},
      I18n.t('cmn_sentence.listTitle', model: '表編集') => {controller: 'grid', action: 'index'}
    }

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
    @var.view_count = @businesses.count
  end

  # ?office_id=?で親の事業所idがわたる
  def new
    @var.title = t('cmn_sentence.newTitle', model: t('cmn_dict.business'))
    @var.mode = "new"
    @var.build_hats_hash(Business, -1)
    @var.build_skills_hash(Business, -1)
    @business = Business.new
    return insert_new_business(params) if request.post?
    @business.init_new_instance(params)
    # pp "  ** business new offers ** "
    # pp @business.offers.size
  end

  def edit
    @var.title = I18n.t("cmn_sentence.editTitle",
      model: I18n.t("cmn_dict.business"),
      id: params[:id])
    @var.mode = params[:id]
    @var.build_hats_hash Business, params[:id]
    @var.build_skills_hash Business, params[:id]
    @business = Business.find(params[:id])

    render "new"
  end

  def update
    @business = Business.find(params[:id])
    save_business(params)
    respond_to do |format|
      format.html {redirect_to action: "edit", id: params[:id]}
      format.json {render :show, status: :created, location: @offer}
    end
  rescue => e
    raise e if Rails.env == 'development'
    respond_to do |format|
      format.html {redirect_to action: "edit", id: params[:id]}
      format.json {render json: format, status: :unprocessable_entity}
    end
  end

  def contact_list

  end

  def search
    @businesses = search_by_post(@var)
    @businesses = Business.all if @businesses.size == 0
    @msg = 'Search done!'
  rescue => e
    logger.debug(e)
    @msg = e.message
  end

  private

    def search_by_post(var)
      cond_list = {name: CondEnum::LIKE, business_type_id: CondEnum::EQ}
      free_word = {keyword: [:description, :welcome]}
      cond_set = self.createCondition(params, cond_list, free_word)
      var.search_cond = cond_set[:cond_param]
      Business.where(cond_set[:cond_arr])
    end

    def insert_new_business(params)
      begin
        Business.transaction do
          @business.attributes = Business.business_params(params, :business)
          @business.save!
          @business.offers.create!(
            title:@business.name,
            description:@business.description,
            offer_status_id: OfferStatus::STATUS_OPEN,
            start_from: @business.scheduled_project_start, #予定開始日
            want_until: @business.end_date, #受付締切
            work_at: params[:business][:offers_attributes]["0"][:work_at]
          )
          @var.update_by_reference Business, @business.id, params
          respond_to do |format|
            format.html {redirect_to(action: 'edit', id: @business.id)}
            format.json {render :show, status: :created, location: @business}
          end
        end
      rescue => e
        raise e if Rails.env == "development"
        flash.now[:alert] = e.message
        respond_to do |format|
          format.html {render 'new'}
          format.json {render json: format, status: :unprocessable_entity}
        end
      end

    end

    def save_business(params)
      Business.transaction do
        @business.attributes = Business.business_params(params, :business)
        @business.save!
        @business.offers[0].update(
          title:@business.name,
          description:@business.description,
          start_from: @business.scheduled_project_start, #予定開始日
          want_until: @business.end_date, #受付締切
          work_at: params[:business][:offers_attributes]["0"][:work_at]
        )
        @var.update_by_reference Business, @business.id, params
      end
    end

end
