import { createSignal, For, Show } from "solid-js";
import type { TrainerSkill } from "@/types/user";
import { Module } from "@/types/module";
import { Icon } from "../Icon";
import useI18n from "@/hooks/useL18N";

interface Props {
    skills: TrainerSkill[];
    allModules: Module[];
    onChange: (skills: TrainerSkill[]) => void;
}

export default function TrainerSkillsManager(props: Props) {
    const { t } = useI18n();
    const [selectedModuleId, setSelectedModuleId] = createSignal<string>("");
    const [competenceLevel, setCompetenceLevel] = createSignal<number>(1);

    const handleAddSkill = () => {
        if (!selectedModuleId()) return;

        const newSkill: TrainerSkill = {
            module_id: selectedModuleId(),
            competence_level: competenceLevel(),
        };

        if (props.skills.some((s) => s.module_id === newSkill.module_id)) {
            const updatedSkills = props.skills.map(s =>
                s.module_id === newSkill.module_id ? newSkill : s
            );
            props.onChange(updatedSkills);
        } else {
            props.onChange([...props.skills, newSkill]);
        }

        setSelectedModuleId("");
        setCompetenceLevel(1);
    };

    const handleRemoveSkill = (moduleId: string) => {
        props.onChange(props.skills.filter((s) => s.module_id !== moduleId));
    };

    const getModuleName = (moduleId: string) => {
        return props.allModules.find((m) => m.module_id === moduleId)?.name || "Unknown Module";
    };

    const availableModules = () => {
        return props.allModules.filter(m => !props.skills.some(s => s.module_id === m.module_id));
    };

    return (
        <div class="mt-4 border-t border-base-300 pt-4">
            <h3 class="font-semibold mb-4 text-sm uppercase opacity-70">
                {t("dashboard.users.trainers.skills")}
            </h3>

            <div class="flex gap-2 mb-4">
                <select
                    class="select select-bordered select-sm w-full max-w-xs"
                    value={selectedModuleId()}
                    onChange={(e) => setSelectedModuleId(e.currentTarget.value)}
                >
                    <option value="" disabled selected>
                        {t("dashboard.users.trainers.select_module")}
                    </option>
                    <For each={availableModules()}>
                        {(module) => (
                            <option value={String(module.module_id)}>{module.name}</option>
                        )}
                    </For>
                </select>

                <input
                    type="number"
                    min="1"
                    max="5"
                    class="input input-bordered input-sm w-20"
                    value={competenceLevel()}
                    onInput={(e) => setCompetenceLevel(Number(e.currentTarget.value))}
                    placeholder="Lvl"
                />

                <button
                    class="btn btn-sm btn-primary"
                    onClick={handleAddSkill}
                    disabled={!selectedModuleId()}
                >
                    <Icon name="Plus" size={16} />
                    {t("entity_table.add")}
                </button>
            </div>

            <div class="space-y-2">
                <Show when={props.skills.length === 0}>
                    <p class="text-sm opacity-50 italic">{t("dashboard.users.trainers.no_skills")}</p>
                </Show>
                <For each={props.skills}>
                    {(skill) => (
                        <div class="flex items-center justify-between p-2 bg-base-200 rounded border border-base-300">
                            <div class="flex items-center gap-2">
                                <span class="font-medium">{getModuleName(skill.module_id)}</span>
                                <span class="badge badge-sm badge-ghost">Lvl {skill.competence_level}</span>
                            </div>
                            <button
                                class="btn btn-xs btn-ghost text-error"
                                onClick={() => handleRemoveSkill(skill.module_id)}
                                title={t("general.remove")}
                            >
                                <Icon name="X" size={14} />
                            </button>
                        </div>
                    )}
                </For>
            </div>
        </div>
    );
}
