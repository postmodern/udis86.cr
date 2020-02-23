require "../src/libudis86"
require "./spec_helper"

Spectator.describe LibUDis86 do
  describe LibUDis86::UDType do
    describe "#none?" do
      subject { LibUDis86::UDType::None }

      it { expect(subject.none?).to be_true }
    end

    describe "#is_op?" do
      {% for element in LibUDis86::UDType.constants %}
        {% if element.starts_with?("OP_") %}
          context "{{ element.id }}" do
            subject { LibUDis86::UDType::{{ element.id }} }

            it { expect(subject.is_op?).to be_true }
          end
        {% end %}
      {% end %}
    end

    describe "#is_reg?" do
      {% for element in LibUDis86::UDType.constants %}
        {% if element.starts_with?("R_") %}
          context "{{ element.id }}" do
            subject { LibUDis86::UDType::{{ element.id }} }

            it { expect(subject.is_reg?).to be_true }
          end
        {% end %}
      {% end %}
    end
  end
end
