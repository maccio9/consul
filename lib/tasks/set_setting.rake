namespace :set_setting do

  desc "Set settings data"
  task set_data: :environment do
    #set modules
    Setting['feature.debates'] = false
    Setting['feature.proposals'] = false
    Setting['feature.legislation_proposals'] = true
    Setting['feature.spending_proposals'] = false
    Setting['feature.polls'] = false
    Setting['feature.twitter_login'] = false
    Setting['feature.facebook_login'] = false
    Setting['feature.google_login'] = false
    Setting['feature.public_stats'] = false
    Setting['feature.budgets'] = false
    Setting['feature.signature_sheets'] = false
    Setting['feature.legislation'] = false
    Setting['feature.user.recommendations'] = false
    Setting['feature.community'] = false
    Setting['feature.map'] = nil
    Setting['feature.allow_images'] = true
    Setting['feature.guides'] = nil

    #set proposal
    setting = Setting.find_by_key 'proposals_require_admin'
    if setting.blank?
      Setting['proposals_require_admin'] = nil
    end
    setting = Setting.find_by_key 'auto_publish_comments'
    if setting.blank?
      Setting['auto_publish_comments'] = "true"
    end
    setting = Setting.find_by_key 'proposals_start_date'
    if setting.blank?
      Setting['proposals_start_date'] = Date.today - 20.days
    end
    setting = Setting.find_by_key 'proposals_end_date'
    if setting.blank?
      Setting['proposals_end_date'] = Date.today + 100.days
    end

    # set mailer
    Setting['mailer_from_name'] = 'Gobierno Abierto'
    Setting['mailer_from_address'] = 'gobiernoabierto@agesic.gub.uy'

    #create user admin
    if User.where(email: 'jose.poncedeleon@agesic.gub.uy').empty?
      pass = SecureRandom.hex(8)
      admin = User.create!(username: 'jose.poncedeleon', email: 'jose.poncedeleon@agesic.gub.uy', password: pass, password_confirmation: pass, confirmed_at: Time.current, terms_of_service: "1")
      admin.residence_verified_at = Date.today
      admin.level_two_verified_at = Date.today
      admin.save
      admin.create_administrator
    end
    #set meta tags
    Setting["meta_title"] = '4to Plan de Acción Nacional 2018 - 2020'
    Setting["meta_description"] = 'Proponé y participa: Podés presentar propuestas y hacer comentarios hasta el 17 de junio de 2018. Proponé ideas o iniciativas que fortalezcan la transparencia, el acceso a la información pública, la rendición de cuentas, la participación y la colaboración ciudadana.'
    Setting["meta_keywords"] = "4to Plan de Acción Nacional"

    # set data home
    Setting["title_home"] = "Proponé y participá"
    Setting["sub_title_home"] = "Podés presentar propuestas y hacer comentarios hasta el 30 de junio de 2018."
    Setting["description_home"] = "Proponé ideas o iniciativas que fortalezcan la transparencia, el acceso a la información pública, la rendición de cuentas, la participación y la colaboración ciudadana."
    Setting["title_link_home"] = "Ver propuestas"
    Setting["url_link_home"] = "https://plan.gobiernoabierto.gub.uy/proposals?is_proposal=true"
    Setting['feature.legislation_proposals'] = true

    #set data legislation proposal
    setting = Setting.find_by_key 'legislation_proposals_start_date'
    if setting.blank?
      Setting['legislation_proposals_start_date'] = Date.today
    end
    setting = Setting.find_by_key 'legislation_proposals_end_date'
    if setting.blank?
      Setting['legislation_proposals_end_date'] = Date.today + 20.days
    end
    setting = Setting.find_by_key 'legislation_proposals_require_admin'
    Setting['legislation_proposals_require_admin'] = 'true'

    #set config categories
    Setting['categories_legislation_proposals_is_visible'] = 'true'
    Setting['categories_legislation_proposals_name'] = 'Categorias'
    Setting['categories_legislation_proposals_help_text'] = 'Seleccione una o más categorías del tema de su propuesta'
    Setting['group_legislation_proposals_is_visible'] = 'true'
    Setting['group_legislation_proposals_name'] = 'Aporta a'
    Setting['description_header_legislation_proposals'] = 'A través de la consulta pública podrás conocer los compromisos que integrarán el 4to plan de Acción de Gobierno Abierto, y realizar aportes que enriquezcan cada una de las iniciativas.'
    Setting['description_header_proposals'] = "Finalizó el plazo para ingresar nuevas propuestas. El Grupo de Trabajo de Gobierno Abierto y los organismos del Estado se encuentran analizando todas la propuestas"
    Setting['home_title_stages'] = 'Etapas del proceso de cocreación'
    Setting['home_title_stages_1'] = 'crear'
    Setting['home_description_stages_1'] = 'presentá tus propuestas'
    Setting['home_date_stages_1'] = 'Hasta el 30 de junio'
    Setting['home_title_stages_2'] = 'priorizar'
    Setting['home_description_stages_2'] = 'el grupo de trabajo las priorizará'
    Setting['home_date_stages_2'] = 'Junio/Julio'
    Setting['home_title_stages_3'] = 'consultar'
    Setting['home_description_stages_3'] = 'participá de la consulta pública'
    Setting['home_date_stages_3'] = 'Hasta el 7 de setiembre'
    Setting['home_title_stages_4'] = 'aprobar'
    Setting['home_description_stages_4'] = 'los compromisos serán aprobados por el Poder Ejecutivo'
    Setting['home_date_stages_4'] = 'Setiembre'
    Setting['header_title'] = 'Gobierno Abierto.'
    Setting['header_sub_title'] = '4to Plan de Acción Nacional 2018 - 2020'
  end

end
