

with  GAB as (
select mv_entity.household_id
      ,'Y' as GAB
from v_committee_gab
inner join mv_entity on mv_entity.donor_id = v_committee_gab.constituent_donor_id
where involvement_role = 'Member'
)

, BOT_and_Alumni as (
select mv_entity.household_id
      ,'Y' as BOT
from v_committee_trustee
inner join mv_entity on mv_entity.donor_id = v_committee_trustee.constituent_donor_id
inner join mv_entity_ksm_degrees on mv_entity_ksm_degrees.donor_id = v_committee_trustee.constituent_donor_id
)


-- confirm with liam that the data in CATco is correct, if not, create a temp table
, CSM as (
select mv_entity.household_id
      ,'Y' as CSM
from stg_alumni.ucinn_ascendv2__society_membership__c
inner join mv_entity on mv_entity.donor_id = stg_alumni.ucinn_ascendv2__society_membership__c.ucinn_ascendv2__donor_id_formula__c
where ap_giving_society_name_text__C = 'KSM Cornerstone Donors'
and ucinn_ascendv2__membership_status__c = 'Active'
)

, ebfa as (
select mv_entity.household_id
      ,'Y' as ebfa
from v_committee_asia
inner join mv_entity on mv_entity.donor_id = v_committee_asia.constituent_donor_id
)

, dfc_visit_any_year as (
select distinct mv_entity.household_id
      ,'Y' as dfc_visit_any_year
from stg_alumni.ucinn_ascendv2__contact_report__c
inner join mv_entity on mv_entity.salesforce_id = stg_alumni.ucinn_ascendv2__contact_report__c.ucinn_ascendv2__contact__c
where ucinn_ascendv2__contact_method__c = 'Visit'
and ap_contact_report_author_constituent__c = '003Uz000008fdsIIAQ' -- DFC
)

, dfc_visit_past_year as (
select distinct mv_entity.household_id
      ,'Y' as dfc_visit_past_year
from stg_alumni.ucinn_ascendv2__contact_report__c
inner join mv_entity on mv_entity.salesforce_id = stg_alumni.ucinn_ascendv2__contact_report__c.ucinn_ascendv2__contact__c
cross join v_current_calendar
where ucinn_ascendv2__contact_method__c = 'Visit'
and ap_contact_report_author_constituent__c = '003Uz000008fdsIIAQ' -- DFC
and ucinn_ascendv2__date__c >= v_current_calendar.yesterday_last_year
)

, planned_gift_donor as (
select distinct household_id
       ,'Y' as planned_gift_donor
from mv_ksm_transactions
where opportunity_type in (
'PGRLE (Retained Life Estate)'
,'PGPIF (Pooled Income Fund)'
,'PGIRA (Distribution from IRA)'
,'PGEST (Realized Estate Gift)'
,'PGCRUT (Charitable Remainder Unitrust)'
,'PGCRAT (Charitable Remainder Annuity Trust)'
,'PGCGA (Charitable Gift Annuity)'
,'PGBEQ (Revocable Bequest)'
,'Life Insurance'
,'Lead Trust'
)
and recognition_credit > 0
and opportunity_stage = 'Active'
)

, kac as (
select mv_entity.household_id
      , 'Y' as kac
from v_committee_kac
inner join mv_entity on mv_entity.donor_id = v_committee_kac.constituent_donor_id
)

, pevc as (
select mv_entity.household_id
      ,'Y' as pevc
from v_committee_privateequity
inner join mv_entity on mv_entity.donor_id = v_committee_privateequity.constituent_donor_id
)

, mbai as (
select mv_entity.household_id
      ,'Y' as mbai
from v_committee_mbai
inner join mv_entity on mv_entity.donor_id = v_committee_mbai.constituent_donor_id
)

, healthcare as (
select mv_entity.household_id
      ,'Y' as healthcare
from v_committee_healthcare 
inner join mv_entity on mv_entity.donor_id = v_committee_healthcare.constituent_donor_id
)

, realestate as (
select mv_entity.household_id
      ,'Y' as realestate
from v_committee_realestcouncil 
inner join mv_entity on mv_entity.donor_id = v_committee_realestcouncil.constituent_donor_id
)

, amp as (
select mv_entity.household_id
      ,'Y' as amp
from v_committee_amp
inner join mv_entity on mv_entity.donor_id = v_committee_amp.constituent_donor_id
)

, phs as (
select mv_entity.household_id
      ,'Y' as phs
from v_committee_phs
inner join mv_entity on mv_entity.donor_id = v_committee_phs.constituent_donor_id
)

/*
, event_attendee as (

)
*/

, campaign_credit as (
select household_id
, gs.full_circle_recognition
, Case
  When gs.full_circle_recognition >= 1E6 Then '$1M+'
  When gs.full_circle_recognition >= 100E3 Then '$100K+'
  -- etc
  End
  As full_circle_recognition_band
from mv_ksm_giving_summary gs
Where gs.full_circle_recognition > 0
)

, campaign_donor as (
select household_id
from mv_ksm_giving_summary gs
where ngc_cfy > 0 -- fy25
or ngc_pfy1 > 0 --fy24
or ngc_pfy2 > 0 --fy23
or ngc_pfy3 > 0 -- fy22
)

, campaign_donor_100k as (
select household_id
from mv_ksm_giving_summary
where (ngc_cfy + ngc_pfy1 + ngc_pfy2 + ngc_pfy3) >= 100000
)

, campaign_donor_1M as (
select household_id
from mv_ksm_giving_summary
where (ngc_cfy + ngc_pfy1 + ngc_pfy2 + ngc_pfy3) >= 1000000
)

, asia_pevc as (
select mv_entity.household_id
      ,'Y' as asia_pevc
from v_committee_pe_asia
inner join mv_entity on mv_entity.donor_id = v_committee_pe_asia.constituent_donor_id
)

, club_leader as (
select distinct mv_entity.household_id
      ,'Y' as clun_leader
from mv_involvement
inner join mv_entity on mv_entity.donor_id = mv_involvement.constituent_donor_id
where involvement_role IN ('Club Leader'
                           ,'President'
                           ,'President-Elect'
                           ,'Director'
                           ,'Secretary'
                           ,'Treasurer'
                           ,'Executive')
--- Current will suffice for the date
and involvement_status = 'Current'
and (involvement_name  like '%Kellogg%'
or involvement_name  like '%KSM%')
)


, yab as (
select mv_entity.household_id
      ,'Y' as yab
from v_committee_yab
inner join mv_entity on mv_entity.donor_id = v_committee_yab.constituent_donor_id
)

, tech as (
select mv_entity.household_id
      ,'Y' as tech
from v_committee_tech
inner join mv_entity on mv_entity.donor_id = v_committee_tech.constituent_donor_id
)

, kfn_associate as (
select mv_entity.household_id
      ,'Y' as kfn_associate
from v_committee_kfn
inner join mv_entity on mv_entity.donor_id = v_committee_kfn.constituent_donor_id
where involvement_role = 'Associate Member'
)


, Professional_list_Recipient as (
select mv_entity.household_id
      ,holiday_card_professional.professional_list_recipient
      ,holiday_card_professional.xcomment
from holiday_card_professional
inner join mv_entity on mv_entity.donor_id = holiday_card_professional.id_number
)

, personalized_list_Recipient as (
select mv_entity.household_id
      ,holiday_card_personalized.personalized_list_recipient
      ,holiday_card_personalized.xcomment
from holiday_card_personalized
inner join mv_entity on mv_entity.donor_id = holiday_card_personalized.id_number
)

, vendor_list_Recipient as (
select mv_entity.household_id
      ,holiday_card_vendor.vendor_list_recipient
      ,holiday_card_vendor.xcomment
from holiday_card_vendor
inner join mv_entity on mv_entity.donor_id = holiday_card_vendor.id_number
)

/*
, professional_fy25_manual_adds as (
select mv_entity.household_id
from mv_entity
where mv_entity.donor_id in (

)
)
*/

/*
, personalized_fy25_manual_adds as (
select mv_entity.household_id
from mv_entity
where mv_entity.donor_id in (

)
)
*/

/*
, vendor_fy25_manual_adds as (
select mv_entity.household_id
from mv_entity
where mv_entity.donor_id in (

)
)
*/


, last_gift as (
select household_id
      ,last_ngc_tx_id
      ,last_ngc_date
      ,last_ngc_opportunity_type
      ,last_ngc_designation_id
      ,last_ngc_designation
      ,last_ngc_recognition_credit
from mv_ksm_giving_summary
)

, family as ( --- ask if relationship code has already been built
select *
from stg_alumni.ucinn_ascendv2__contact_report_relation__c
inner join mv_entity on mv_entity.salesforce_id = stg_alumni.ucinn_ascendv2__contact_report_relation__c.ucinn_ascendv2__contact__c
where mv_entity.household_id = 0000648089
)
