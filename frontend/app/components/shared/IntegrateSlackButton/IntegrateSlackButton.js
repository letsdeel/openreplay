import React from 'react'
import { Button, Icon } from 'UI'
import { CLIENT_TABS, client as clientRoute } from 'App/routes';
import { withRouter } from 'react-router-dom';

function IntegrateSlackTeamsButton({ history }) {

  const gotoPreferencesIntegrations = () => {
    history.push(clientRoute(CLIENT_TABS.INTEGRATIONS));
  }

  return (
    <div>
      <Button
        className="my-auto mt-2 mb-2 flex items-center gap-2"
        onClick={gotoPreferencesIntegrations}
        variant="text-primary"
      >
        <Icon name="integrations/slack" size={16} />
        <Icon name="integrations/teams" size={24} className="mr-2 ml-1" />

        <span>Integrate Slack or MS Teams</span>
      </Button>
    </div>
  )
}

export default withRouter(IntegrateSlackTeamsButton)
