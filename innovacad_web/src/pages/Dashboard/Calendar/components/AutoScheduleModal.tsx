import { createSignal, Show } from "solid-js";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";

interface AutoScheduleModalProps {
    isOpen: boolean;
    onClose: () => void;
    classId: string;
    onSuccess?: () => void;
}

const AutoScheduleModal = (props: AutoScheduleModalProps) => {
    const api = useApi();
    const [loading, setLoading] = createSignal(false);
    const [startDate, setStartDate] = createSignal("");
    const [regimeType, setRegimeType] = createSignal("0");
    const [isOnline, setIsOnline] = createSignal(false);

    const handleSubmit = async (e: Event) => {
        e.preventDefault();
        if (!props.classId) {
            toast.error("No class selected");
            return;
        }
        if (!startDate()) {
            toast.error("Please select a start date");
            return;
        }

        setLoading(true);
        try {
            const date = new Date(startDate());
            const isoDate = date.toISOString();

            await api.generateAutoSchedule({
                class_id: props.classId,
                start_date: isoDate,
                regime_type: parseInt(regimeType()),
                is_online: isOnline(),
            });
            toast.success("Schedule generated successfully");
            props.onSuccess?.();
            props.onClose();
        } catch (error: any) {
            toast.error(error.message || "Failed to generate schedule");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Show when={props.isOpen}>
            <div class="modal modal-open">
                <div class="modal-box">
                    <h3 class="font-bold text-lg mb-4">Generate Auto Schedule</h3>
                    <form onSubmit={handleSubmit}>
                        <div class="form-control w-full mb-4">
                            <label class="label">
                                <span class="label-text">Start Date</span>
                            </label>
                            <input
                                type="date"
                                class="input input-bordered w-full"
                                value={startDate()}
                                onInput={(e) => setStartDate(e.currentTarget.value)}
                                required
                            />
                        </div>

                        <div class="form-control w-full mb-4">
                            <label class="label">
                                <span class="label-text">Regime Type</span>
                            </label>
                            <select
                                class="select select-bordered w-full"
                                value={regimeType()}
                                onChange={(e) => setRegimeType(e.currentTarget.value)}
                            >
                                <option value="0">Diurno</option>
                                <option value="1">Pós-Laboral</option>
                            </select>
                        </div>

                        <div class="form-control w-full mb-6">
                            <label class="label cursor-pointer justify-start gap-4">
                                <span class="label-text">Is Online?</span>
                                <input
                                    type="checkbox"
                                    class="checkbox checkbox-primary"
                                    checked={isOnline()}
                                    onChange={(e) => setIsOnline(e.currentTarget.checked)}
                                />
                            </label>
                        </div>

                        <div class="modal-action">
                            <button
                                type="button"
                                class="btn"
                                onClick={props.onClose}
                                disabled={loading()}
                            >
                                Cancel
                            </button>
                            <button
                                type="submit"
                                class="btn btn-primary"
                                disabled={loading()}
                            >
                                {loading() ? <span class="loading loading-spinner"></span> : "Generate"}
                            </button>
                        </div>
                    </form>
                </div>
                <div class="modal-backdrop" onClick={props.onClose}></div>
            </div>
        </Show>
    );
};

export default AutoScheduleModal;
