# Copyright © 2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe "User submitting a ServiceRequest", js: true do
  def click_add_service_for(service)
    page.find("button[data-id='#{service.id}']").click
    wait_for_javascript_to_finish
  end

  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  it "is happy" do
    # Organization structure and Services:
    institution = create(:organization, type: "Institution")

    provider_non_split = create(:organization, :with_pricing_setup, type: "Provider", parent_id: institution.id)
    provider_split = create(:organization, :with_pricing_setup, type: "Provider", process_ssrs: true, parent_id: institution.id)

    program_split = create(:organization, type: "Program", process_ssrs: true, parent_id: provider_non_split.id)
    program_non_split = create(:organization, type: "Program", parent_id: provider_split.id)

    core1 = create(:organization, type: "Core", parent_id: program_split.id)
    core2 = create(:organization, type: "Core", parent_id: program_non_split.id)

    otf_service_core_1 = create(:one_time_fee_service, :with_pricing_map, organization_id: core1.id)
    pppv_service_core_1 = create(:per_patient_per_visit_service, :with_pricing_map, organization_id: core1.id)
    otf_service_core_2 = create(:one_time_fee_service, :with_pricing_map, organization_id: core2.id)
    pppv_service_core_2 = create(:per_patient_per_visit_service, :with_pricing_map, organization_id: core2.id)

    # Visit catalog page
    visit "/"
    wait_for_javascript_to_finish

    # Log in:
    click_link("Login / Sign Up")
    wait_for_javascript_to_finish
    expect(page).to have_css("a", text: /Outside User Login/)
    find("a", text: /Outside User Login/).click
    wait_for_javascript_to_finish
    fill_in "Login", with: "johnd"
    fill_in "Password", with: "p4ssword"
    find("input[value='Login']").click
    wait_for_javascript_to_finish

    # Add Core 1 Services
    expect(page).to have_css("span", text: provider_non_split.name)
    find("span", text: provider_non_split.name).click
    wait_for_javascript_to_finish
    find("span", text: program_split.name).click
    wait_for_javascript_to_finish
    find("span", text: core1.name).click
    wait_for_javascript_to_finish
    expect(page).to have_content(otf_service_core_1.name)
    expect(page).to have_content(pppv_service_core_1.name)
    click_add_service_for(otf_service_core_1)
    expect(page).to have_css("a", text: "Yes (Continue with Shopping Cart)")
    find("a", text: /Yes/).click
    within(".shopping-cart") do
      expect(page).to have_content(otf_service_core_1.abbreviation)
    end
    click_add_service_for(pppv_service_core_1)
    within(".shopping-cart") do
      expect(page).to have_content(pppv_service_core_1.abbreviation)
    end

    # Add Core 2 Services
    find("span", text: provider_split.name).click
    wait_for_javascript_to_finish
    find("span", text: program_non_split.name).click
    wait_for_javascript_to_finish
    find("span", text: core2.name).click
    wait_for_javascript_to_finish
    expect(page).to have_content(otf_service_core_2.name)
    expect(page).to have_content(pppv_service_core_2.name)
    click_add_service_for(otf_service_core_2)
    within(".shopping-cart") do
      expect(page).to have_content(otf_service_core_2.abbreviation)
    end
    click_add_service_for(pppv_service_core_2)
    within(".shopping-cart") do
      expect(page).to have_content(pppv_service_core_2.abbreviation)
    end

    wait_for_javascript_to_finish
    find("a", text: /Continue/).click
    wait_for_javascript_to_finish

    # Step 1
    expect(page).to have_link("New Project")
    click_link("New Project")
    wait_for_javascript_to_finish
    fill_in("Short Title:", with: "My Protocol")
    fill_in("Project Title:", with: "My Protocol is Very Important - #12345")
    click_button("Select a Funding Status")
    find("li", text: "Funded").click
    expect(page).to have_button("Select a Funding Source")
    click_button("Select a Funding Source")
    find("li", text: "Federal").click
    fill_in "Primary PI:", with: "john"

    expect(page).to have_css("div.tt-selectable", text: /johnd@musc.edu/)
    first("div.tt-selectable", text: /johnd@musc.edu/).click
    find("input[value='Save']").click
    wait_for_javascript_to_finish

    expect(page).to have_css("a", text: /Save and Continue/)
    find("a", text: /Save and Continue/).click
    wait_for_javascript_to_finish

    # Step 2A
    expect(page).to have_css('#project_start_date')
    find('#project_start_date').click
    within(".bootstrap-datetimepicker-widget") do
      first("td.day", text: "1").click
    end
    find('#project_end_date').click
    within(".bootstrap-datetimepicker-widget") do
      first("td.day", text: "1").click
    end
    find("a", text: /Save and Continue/).click
    wait_for_javascript_to_finish

    # Step 2B
    # Set visit day
    expect(page).to have_css("a", text: "(?)")
    find("a", text: "(?)").click
    fill_in 'visit_group_day', with: 1
    click_button 'Save changes'
    find("a", text: /Save and Continue/).click
    wait_for_javascript_to_finish

    # Step 3
    expect(page).to have_css("a", text: /Save and Continue/)
    find("a", text: /Save and Continue/).click
    wait_for_javascript_to_finish

    # Step 4
    expect(page).to have_css("a", text: /Submit Request/)
    find("a", text: /Submit Request/).click
    wait_for_javascript_to_finish

    # Don't take survey
    # TODO excerise taking survey and submitting it.
    expect(page).to have_css(".modal-dialog a", text: /No/)
    find(".modal-dialog a", text: /No/).click
    wait_for_javascript_to_finish

    # Step 5
    expect(page).to have_css("a", text: /Go to Dashboard/)
    find("a", text: /Go to Dashboard/).click
    wait_for_javascript_to_finish

    # Dashboard
    expect(page).to have_content("My Protocol")
  end
end
