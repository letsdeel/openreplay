import React from 'react';
import { Button, Space } from 'antd';
import { filtersMap } from 'Types/filter/newFilter';
import { Empty } from 'antd';
import { Info } from 'lucide-react';
import { ArrowRight } from 'lucide-react';
import CardSessionsByList from 'Components/Dashboard/Widgets/CardSessionsByList';
import { useModal } from 'Components/ModalContext';
import Widget from '@/mstore/types/widget';

interface Props {
  metric?: any;
  data: any;
  onClick?: (filters: any) => void;
  isTemplate?: boolean;
}

function SessionsBy(props: Props) {
  const { metric = {}, data = { values: [] }, onClick = () => null, isTemplate } = props;
  const [selected, setSelected] = React.useState<any>(null);
  const total = data.total;
  const { openModal, closeModal } = useModal();
  const modalMetric = React.useMemo(() => Object.assign(new Widget(), metric), [metric]);

  const onClickHandler = (event: any, data: any) => {
    const baseFilter = {
      ...filtersMap[metric.metricOf],
      value: [data.name],
      type: filtersMap[metric.metricOf].key,
      filters: filtersMap[metric.metricOf].filters?.map((f: any) => {
        const { key, operatorOptions, category, icon, label, options, ...cleaned } = f;
        return { ...cleaned, type: f.key, value: [] };
      })
    };

    const { key, operatorOptions, category, icon, label, options, ...finalFilter } = baseFilter;

    setSelected(data.name);
    onClick([finalFilter]);
  };

  const showMore = (e: any) => {
    e.stopPropagation();
    openModal(
      <CardSessionsByList
        paginated={true}
        metric={modalMetric}
        total={total}
        list={data.values}
        onClickHandler={(e, item) => {
          closeModal();
          onClickHandler(null, item);
        }} selected={selected} />, {
        title: metric.name,
        width: 600
      });
  };

  return (
    <div>
      {data.values && data.values.length === 0 ? (
        <Empty
          image={null}
          style={{ minHeight: 220 }}
          className="flex flex-col items-center justify-center"
          imageStyle={{ height: 0 }}
          description={
            <div className="flex items-center gap-2 justify-center text-black">
              <Info size={14} />
              No data available for the selected period.
            </div>
          }
        />
      ) : (
        <div className="flex flex-col justify-between w-full" style={{ height: 220 }}>
          {metric && <CardSessionsByList list={data.values.slice(0, 3)}
                                         selected={selected}
                                         onClickHandler={onClickHandler} />}
          {total > 3 && (
            <div className="flex">
              <Button type="link" onClick={showMore}>
                <Space className="flex font-medium gap-1">
                  {total - 3} More
                  <ArrowRight size={16} />
                </Space>
              </Button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default SessionsBy;
