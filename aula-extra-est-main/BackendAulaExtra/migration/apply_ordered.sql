-- apply_ordered.sql
-- Script de bootstrap/migração para o projeto Aula Extra.
-- Objetivo: aplicar APENAS o schema e procs deste projeto (evita tabelas de ecommerce/Stripe/Orders/etc).

-- 1) Bootstrap base (extensions + schema)
\ir '../ConfidantPostgreSQL/docker/init-postgres-schema.sql'


-- 3) Tabelas auxiliares usadas por módulos (public.*)
\ir '../src/Modules/Users/Sql/ddl/create_users_table.sql'
\ir '../src/Modules/Users/Sql/ddl/create_role.sql'
\ir '../src/Modules/Users/Sql/ddl/create_userole.sql'
\ir '../src/Modules/Users/Sql/ddl/create_userprofile.sql'
\ir '../src/Modules/Users/Sql/ddl/create_usernotification.sql'
\ir '../src/Modules/Users/Sql/ddl/create_userconsents.sql'
\ir '../src/Modules/UserProfile/Sql/ddl/001_create_userprofiles_table.sql'
\ir '../src/Modules/UserProfile/Sql/ddl/002_add_profile_image_columns.sql'
\ir '../src/Modules/Professors/Sql/ddl/create_professor_rooms.sql'

-- 2) Schema principal da plataforma (tabelas em aula_extra.*)
\ir '../ConfidantPostgreSQL/docker/10-aula-extra-platform-schema.sql'
-- 4) Procedures / Functions (usp_*)

-- 3) Module DDLs (create remaining public.* tables used by procs)
\ir '../src/Modules/Communication/Sql/ddl/communication.sql'
\ir '../src/Modules/Communication/Sql/ddl/chat_files.sql'
\ir '../src/Modules/ContactsForm/Sql/ddl/contacts_form.sql'
\ir '../src/Modules/Favorites/Sql/ddl/favorites.sql'
\ir '../src/Modules/Lessons/Sql/ddl/lesson.sql'
\ir '../src/Modules/Payments/Sql/ddl/payments.sql'
\ir '../src/Modules/Complaints/Sql/ddl/complaints.sql'
\ir '../src/Modules/Courses/Sql/ddl/courses.sql'
\ir '../src/Modules/Education/Sql/ddl/education.sql'
\ir '../src/Modules/Education/Sql/ddl/user_disciplinas.sql'
\ir '../src/Modules/Faq/Sql/ddl/faq.sql'
\ir '../src/Modules/Professors/Sql/ddl/professor.sql'
\ir '../src/Modules/Professors/Sql/ddl/professor_disciplinas.sql'
\ir '../src/Modules/Professors/Sql/ddl/professor_languages.sql'
\ir '../src/Modules/Reservations/Sql/ddl/reservation.sql'
\ir '../src/Modules/Courses/Sql/ddl/lesson_packs.sql'
\ir '../src/Modules/Schedule/Sql/ddl/schedule.sql'

-- 4) Procedures / Functions (usp_*)
-- Users
\ir '../src/Modules/Users/Sql/procs/usp_users_select_by_email01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_select_all01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_insert01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_select_summary01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_select_details01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_select_search01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_select_authentication01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_register02.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_update.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_update_inactive.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_delete.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_select_roles01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_users_update_roles.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userroles_getbyuser.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userroles_deleteall.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userroles_insert.sql'
\ir '../src/Modules/Users/Sql/procs/usp_user_get_id_by_email_and_store.sql'
\ir '../src/Modules/Users/Sql/procs/usp_user_get_by_reset_token_and_store.sql'
\ir '../src/Modules/Users/Sql/procs/usp_user_get_by_email_verification_token.sql'
\ir '../src/Modules/Users/Sql/procs/usp_user_reset_password.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_select_summary01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_select_details01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_select_search01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_insert.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_update.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_delete.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_set_reset_token.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_set_email_verification_token.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userprofile_confirm_email.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userconsents_select_summary01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userconsents_select_details01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userconsents_select_search01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userconsents_insert.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userconsents_update.sql'
\ir '../src/Modules/Users/Sql/procs/usp_userconsents_delete.sql'
\ir '../src/Modules/Users/Sql/procs/usp_usernotifications_select_summary01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_usernotifications_select_details01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_usernotifications_select_search01.sql'
\ir '../src/Modules/Users/Sql/procs/usp_usernotifications_insert.sql'
\ir '../src/Modules/Users/Sql/procs/usp_usernotifications_update.sql'
\ir '../src/Modules/Users/Sql/procs/usp_usernotifications_delete.sql'

-- UserProfile (public.userprofiles)
\ir '../src/Modules/UserProfile/Sql/procs/usp_userprofiles_get_by_id.sql'
\ir '../src/Modules/UserProfile/Sql/procs/usp_userprofiles_get_by_verification_token.sql'
\ir '../src/Modules/UserProfile/Sql/procs/usp_userprofiles_get_by_reset_token.sql'
\ir '../src/Modules/UserProfile/Sql/procs/usp_userprofiles_insert.sql'
\ir '../src/Modules/UserProfile/Sql/procs/usp_userprofiles_update.sql'
\ir '../src/Modules/UserProfile/Sql/procs/usp_userprofiles.sql'

-- AgoraAPI
\ir '../src/Modules/AgoraAPI/Sql/ddl/videocall.sql'
\ir '../src/Modules/AgoraAPI/Sql/ddl/api_data.sql'
\ir '../src/Modules/AgoraAPI/Sql/procs/usp_video_calls.sql'
\ir '../src/Modules/AgoraAPI/Sql/procs/usp_video_call_participants.sql'

-- Schedule
\ir '../src/Modules/Schedule/Sql/procs/usp_days.sql'
\ir '../src/Modules/Schedule/Sql/procs/usp_schedule_blocks.sql'
\ir '../src/Modules/Schedule/Sql/procs/usp_block_parts.sql'

-- Favorites / Wishlist
\ir '../src/Modules/Favorites/Sql/procs/usp_wishlists.sql'
\ir '../src/Modules/Favorites/Sql/procs/usp_wishlist_items.sql'
\ir '../src/Modules/Favorites/Sql/procs/usp_favorites.sql'
\ir '../src/Modules/Favorites/Sql/procs/usp_favorite_items.sql'

-- Education
\ir '../src/Modules/Education/Sql/procs/usp_areas.sql'
\ir '../src/Modules/Education/Sql/procs/usp_disciplinas.sql'
\ir '../src/Modules/Education/Sql/procs/usp_user_disciplinas.sql'
\ir '../src/Modules/Education/Sql/procs/usp_anos_escolaridade.sql'
\ir '../src/Modules/Education/Sql/procs/usp_ciclos_estudo.sql'
\ir '../src/Modules/Education/Sql/procs/usp_ciclos_estudo_anos.sql'

-- FAQ
\ir '../src/Modules/Faq/Sql/procs/usp_faq.sql'

-- Courses
\ir '../src/Modules/Courses/Sql/procs/usp_tutoring_types.sql'
\ir '../src/Modules/Courses/Sql/procs/usp_pricing_models.sql'
\ir '../src/Modules/Courses/Sql/procs/usp_courses.sql'
\ir '../src/Modules/Courses/Sql/procs/usp_course_prices.sql'
\ir '../src/Modules/Courses/Sql/procs/usp_lesson_packs.sql'
\ir '../src/Modules/Courses/Sql/procs/usp_user_lesson_packs.sql'
\ir '../src/Modules/Courses/Sql/procs/usp_pack_transactions.sql'

-- Professors
\ir '../src/Modules/Professors/Sql/procs/usp_professors.sql'
\ir '../src/Modules/Professors/Sql/procs/usp_professor_feedback.sql'
\ir '../src/Modules/Professors/Sql/procs/usp_certificates.sql'
\ir '../src/Modules/Professors/Sql/procs/usp_professor_rooms.sql'
\ir '../src/Modules/Professors/Sql/procs/usp_professor_disciplinas.sql'

-- ProfessorAds (anúncios de professores)
\ir '../src/Modules/ProfessorAds/Sql/ddl/professor_ads.sql'
\ir '../src/Modules/ProfessorAds/Sql/procs/usp_professor_ads.sql'

-- Lessons
\ir '../src/Modules/Lessons/Sql/procs/usp_lessons.sql'
\ir '../src/Modules/Lessons/Sql/procs/usp_lesson_feedback.sql'
\ir '../src/Modules/Lessons/Sql/procs/usp_lesson_prices.sql'
\ir '../src/Modules/Lessons/Sql/procs/usp_lesson_schedule_blocks.sql'
\ir '../src/Modules/Lessons/Sql/procs/usp_enrollments.sql'

-- Student
\ir '../src/Modules/Student/Sql/procs/usp_student_evaluations.sql'
\ir '../src/Modules/Student/Sql/procs/usp_student_professor_evaluations.sql'
\ir '../src/Modules/Student/Sql/procs/usp_student_my_tutors.sql'

-- Complaints
\ir '../src/Modules/Complaints/Sql/procs/usp_complaints.sql'
\ir '../src/Modules/Complaints/Sql/procs/usp_complaint_resolutions.sql'

-- Reservations
\ir '../src/Modules/Reservations/Sql/procs/usp_reservations.sql'
\ir '../src/Modules/Reservations/Sql/procs/usp_exception_rules.sql'
\ir '../src/Modules/Reservations/Sql/procs/usp_exception_requests.sql'

-- Payments
\ir '../src/Modules/Payments/Sql/procs/usp_payment_providers.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_payment_methods.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_wallets.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_transactions.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_invoices.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_topups.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_refunds.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_payouts.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_disputes.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_commission_rules.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_withdrawal_policies.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_withdrawal_requests.sql'
\ir '../src/Modules/Payments/Sql/procs/usp_reservation_payments.sql'
\ir '../src/Modules/ContactsForm/Sql/procs/usp_contact_form_categories.sql'
\ir '../src/Modules/ContactsForm/Sql/procs/usp_contact_form_submissions.sql'