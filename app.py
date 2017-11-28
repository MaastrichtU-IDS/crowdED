# -*- coding: utf-8 -*-
import dash
import dash_core_components as dcc
import dash_html_components as html

app = dash.Dash()

app.layout = html.Div(children=[
    html.H1(children='Crowdsourcing'),

    html.Div(children='''
        Measuring accuracy.
    '''),

    dcc.Graph(
        id='example-graph',
        figure={
            'data': [
                {'x': [1, 2, 3], 'y': [4, 1, 2], 'type': 'bar', 'name': 'Good Worker'},
                {'x': [1, 2, 3], 'y': [2, 4, 5], 'type': 'bar', 'name': 'Poor worker'},
            ],
            'layout': {
                'title': 'Performance'
            }
        }
    )
])

if __name__ == '__main__':
    app.run_server(debug=True)
