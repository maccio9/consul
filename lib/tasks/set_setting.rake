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
    Setting["title_home"] = "Hacé tu propuesta. "
    Setting["sub_title_home"] = ""
    Setting["description_home"] = "Conocé los principios generales de Inteligencia Artificial para el Gobierno Digital y realizá tus aportes, tenés tiempo hasta el …"
    Setting["title_link_home"] = "Ver principios de IA"
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
    Setting['legislation_proposals_categories_is_visible'] = 'false'
    Setting['legislation_proposals_categories_name'] = 'Categorias'
    Setting['legislation_proposals_categories_help_text'] = 'Seleccione una o más categorías del tema de su propuesta'
    Setting['legislation_proposals_group_is_visible'] = 'false'
    Setting['legislation_proposals_group_name'] = 'Aporta a'
    Setting['legislation_proposals_title_header'] = "Consulta Pública"
    Setting['legislation_proposals_description_header'] = 'A través del proceso de consulta pública podrás en la Etapa 1, conocer los principios generales de Inteligencia Artificial para el Gobierno Digital,  realizar tus aportes sobre los principios planteados y proponer nuevos principios para integrar. En la Etapa 3, podrás realizar aportes sobre la Estrategia de IA para el Gobierno Digital. <br><br>En la actualidad, los desafíos políticos, éticos, tecnológicos y sociales que presenta esta tecnología reclaman un abordaje holístico y multidisciplinar que genere confianza, garantice derechos y mejore la calidad de vida de las personas. Para elaborar los documentos se convocó a un grupo interdisciplinario interno de Agesic que analizó, debatió y consensuó la propuesta puesta en consulta pública para desarrollar y aplicar soluciones de IA para el Gobierno Digital.”'
    Setting['legislation_proposals_title_help'] = "Ayuda para participar"
    Setting['legislation_proposals_date_text_finish_comment'] = "25 de Marzo de 2020"
    Setting['proposals_title_help'] = "Ayuda para participar"
    Setting['proposals_title_header'] = "Propuestas"
    Setting['proposals_description_header'] = "Finalizó el plazo para ingresar nuevas propuestas. El Grupo de Trabajo de Gobierno Abierto y los organismos del Estado se encuentran analizando todas la propuestas"
    Setting['home_title_stages'] = 'Etapas del proceso de consulta'
    Setting['home_title_stages_1'] = 'Etapa I'
    Setting['home_description_stages_1'] = 'Principios de IA. Consulta Pública'
    Setting['home_date_stages_1'] = 'Hasta el 8 de abril'
    Setting['home_title_stages_2'] = 'Etapa II'
    Setting['home_description_stages_2'] = 'Principios de IA. Análisis de propuestas'
    Setting['home_date_stages_2'] = 'Hasta el 15 de abril'
    Setting['home_title_stages_3'] = 'Etapa III'
    Setting['home_description_stages_3'] = 'Estrategia de IA. Consulta Pública'
    Setting['home_date_stages_3'] = 'Hasta el 13 de Mayo'
    Setting['home_title_stages_4'] = 'Etapa IV'
    Setting['home_description_stages_4'] = 'Aprobación del Documento final de Estrategia de IA'
    Setting['home_date_stages_4'] = 'Hasta el 15 de Junio'
    Setting['header_title'] = 'Inteligencia Artificial'
    Setting['header_sub_title'] = 'para el Gobierno Digital. Consulta pública'
    Setting['signin_title'] = 'Inteligencia Artificial para el Gobierno Digital. Consulta pública'
    Setting['contact_description'] = 'Por consultas o dudas sobre el proceso, las propuestas o ayuda técnica, contactarse con el Equipo de Gobierno Abierto a <a href="mailto:gobiernoabierto@agesic.gub.uy">gobiernoabierto@agesic.gub.uy</a>'
    Setting['more_information'] = "El proceso de consulta pública tiene como objetivo alcanzar una Estrategia Nacional de Inteligencia Artificial para el Gobierno Digital. El mismo se desarrollará en 4 etapas: I) Principios de IA. Consulta Pública; II) Principios de IA. Análisis de propuestas; III) Estrategia de IA. Consulta Pública y IV) Aprobación del Documento final de Estrategia de IA."
  end

end
