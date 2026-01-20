const Indicator = (props: { label: string; value: number }) => (
  <div class="flex flex-col items-center gap-2">
    <div
      class="radial-progress text-success"
      style={{ "--value": props.value }}
      role="progressbar"
    >
      {props.value}%
    </div>
    <span class="text-sm font-medium opacity-80">{props.label}</span>
  </div>
);

const DashboardHome = () => {
  return (
    <div class="space-y-8">
      <section>
        <h2 class="text-lg font-semibold mb-4">Indicadores</h2>

        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
              <Indicator label="OEE" value={82} />
              <Indicator label="Disponibilidade" value={13} />
              <Indicator label="Qualidade" value={91} />
              <Indicator label="Desempenho" value={75} />
            </div>
          </div>
        </div>
      </section>

      <section>
        <h2 class="text-lg font-semibold mb-4">Faturação & Custos</h2>

        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <p class="opacity-70">
              Gráficos e dados financeiros aparecerão aqui.
            </p>
          </div>
        </div>
      </section>
    </div>
  );
};

export default DashboardHome;
