# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.describe VisitGroupsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#update' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should assign @visit_group' do
      protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr        = create(:service_request_without_validations, protocol: protocol)
      arm       = create(:arm, protocol: protocol, name: "Armada")
      vg        = create(:visit_group, arm: arm, day: 1, name: "Visit Me Baby One More Time")
      vg_params = { day: 5 }

      session[:service_request_id] = sr.id

      xhr :put, :update, {
        id: vg.id,
        visit_group: vg_params
      }

      expect(assigns(:visit_group)).to eq(vg.reload)
    end

    context 'visit group valid' do
      it 'should update visit group' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        arm       = create(:arm, protocol: protocol, name: "Armada")
        vg        = create(:visit_group, arm: arm, day: 1, name: "Visit Me Baby One More Time")
        vg_params = { day: 5 }

        session[:service_request_id] = sr.id

        xhr :put, :update, {
          id: vg.id,
          visit_group: vg_params
        }

        expect(vg.reload.day).to eq(5)
      end

      it 'should render nothing' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        arm       = create(:arm, protocol: protocol, name: "Armada")
        vg        = create(:visit_group, arm: arm, day: 1, name: "Visit Me Baby One More Time")
        vg_params = { day: 5 }

        session[:service_request_id] = sr.id

        xhr :put, :update, {
          id: vg.id,
          visit_group: vg_params
        }

        expect(response.body).to be_blank        
      end

      it 'should respond ok' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        arm       = create(:arm, protocol: protocol, name: "Armada")
        vg        = create(:visit_group, arm: arm, day: 1, name: "Visit Me Baby One More Time")
        vg_params = { day: 5 }

        session[:service_request_id] = sr.id

        xhr :put, :update, {
          id: vg.id,
          visit_group: vg_params
        }

        expect(controller).to respond_with(:ok)
      end
    end

    context 'visit group invalid' do
      it 'should not update visit group' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        arm       = create(:arm, protocol: protocol, name: "Armada")
        vg        = create(:visit_group, arm: arm, day: 1, name: "Visit Me Baby One More Time")
        vg_params = { name: nil }

        session[:service_request_id] = sr.id

        xhr :put, :update, {
          id: vg.id,
          visit_group: vg_params
        }

        expect(vg.reload.name).to eq("Visit Me Baby One More Time")
      end

      it 'should render json errors' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        arm       = create(:arm, protocol: protocol, name: "Armada")
        vg        = create(:visit_group, arm: arm, day: 1, name: "Visit Me Baby One More Time")
        vg_params = { name: nil }

        session[:service_request_id] = sr.id

        xhr :put, :update, {
          id: vg.id,
          visit_group: vg_params
        }

        expect(JSON.parse(response.body)).to be
      end

      it 'should respond unprocessable entity' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        arm       = create(:arm, protocol: protocol, name: "Armada")
        vg        = create(:visit_group, arm: arm, day: 1, name: "Visit Me Baby One More Time")
        vg_params = { name: nil }

        session[:service_request_id] = sr.id

        xhr :put, :update, {
          id: vg.id,
          visit_group: vg_params
        }

        expect(controller).to respond_with(:unprocessable_entity)
      end
    end
  end
end
